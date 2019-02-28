//
//  HttpHandler.swift
//  Aqueduct
//
//  Created by Marcus Smith on 2/24/19.
//

import NIO
import NIOHTTP1

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
        print("Handler added")
        // TODO: Create byte buffer for channel here instead of per request
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        print("Channel Read")
        let reqPart = self.unwrapInboundIn(data)
        switch reqPart {
        case .head(let head):
            currentRequest = Request(head: head, buffer: ctx.channel.allocator.buffer(capacity: 0))
        case .body(var bodyBuffer):
            currentRequest!.buffer.write(buffer: &bodyBuffer) // TODO: Handle currentRequest being nil?
        case .end(let trailingHeaders):
            currentRequest!.trailingHeaders = trailingHeaders // TODO: Handle currentRequest being nil?
            requestChannel.handleRequest(request: currentRequest!)
        }
    }
    
    func channelReadComplete(context: ChannelHandlerContext) {
        print("Channel Read Complete")
        context.flush()
    }
}
