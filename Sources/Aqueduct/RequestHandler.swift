//
//  HttpHandler.swift
//  Aqueduct
//
//  Created by Marcus Smith on 2/24/19.
//

import NIO
import NIOHTTP1
import Promises

final class RequestHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    
    private let requestChannel: RequestChannel
    private var currentRequest: Request?
    private var buffer: ByteBuffer!
    
    init(requestChannel: RequestChannel) {
        self.requestChannel = requestChannel
    }
    
    func handlerAdded(ctx: ChannelHandlerContext) {
        print("Handler Added")
        buffer = ctx.channel.allocator.buffer(capacity: 0)
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        print("Channel Read")
        let reqPart = self.unwrapInboundIn(data)
        switch reqPart {
        case .head(let head):
            currentRequest = Request(head: head)
        case .body(var bodyBuffer):
            buffer.write(buffer: &bodyBuffer)
        case .end(let trailingHeaders):
            guard let request = currentRequest else {
                buffer.clear()
                fatalError("Where'd that request go?") // FIXME: Deal with this? Just return?
            }
            
            request.trailingHeaders = trailingHeaders
            request.body.write(buffer.slice())
            currentRequest = nil
            buffer.clear()
            
            do {
                let response = try await(requestChannel.entryPoint.handle(request: request))
                respond(to: request, with: response, in: ctx)
            } catch {
                let response = requestChannel.transform(error)
                respond(to: request, with: response, in: ctx)
            }
            
        }
    }
    
    private func respond(to request: Request, with response: Response, in ctx: ChannelHandlerContext) {
        var head = HTTPResponseHead(version: request.head.version, status: HTTPResponseStatus(statusCode: response.statusCode), headers: response.headers)
        if let data = response.body.data {
            buffer.write(bytes: data)
        }
        head.headers.add(name: "Content-Length", value: "\(buffer.readableBytes)")
        head.headers.replaceOrAdd(name: "Connection", value: request.head.isKeepAlive ? "keep-alive" : "close")
        
        let completePromise: EventLoopPromise<Void>? = request.head.isKeepAlive ? nil : ctx.eventLoop.newPromise()
        completePromise?.futureResult.whenComplete {
            ctx.close(promise: nil)
        }
        
        ctx.write(wrapOutboundOut(.head(head)), promise: nil)
        ctx.write(wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
        ctx.writeAndFlush(wrapOutboundOut(.end(response.trailingHeaders)), promise: completePromise)
    }
    
    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
}
