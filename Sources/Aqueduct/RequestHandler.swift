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
    
    init(requestChannel: RequestChannel) {
        self.requestChannel = requestChannel
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        print("Channel read called")
    }
}
