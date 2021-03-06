//
//  Server.swift
//  Aqueduct
//
//  Created by Marcus Smith on 2/24/19.
//

import Foundation

import Foundation
import Utility
import Promises
import NIO
import NIOHTTP1

public class Server {
    public struct Configuration {
        static let usage = "usage" // TODO: Write good usage message
        static let overview = "overview" // TODO: Write good overview message
        static let hostUsage: String? = nil
        static let portUsage: String? = nil
        static let channelCountUsage: String? = nil
        static let defaultHost = "localhost"
        static let defaultPort = 8080
        static let defaultChannelCount = System.coreCount
        
        public let host: String
        public let port: Int
        public let channelCount: Int
        
        static func from(_ args: [String]) throws -> Configuration {
            let parser = ArgumentParser(usage: Configuration.usage, overview: Configuration.overview)
            let hostOption = parser.add(option: "--host", shortName: "-h", kind: String.self, usage: Configuration.hostUsage, completion: nil)
            let portOption = parser.add(option: "--port", shortName: "-p", kind: Int.self, usage: Configuration.portUsage, completion: nil)
            let channelCountOption = parser.add(option: "--channel-count", shortName: "-c", kind: Int.self, usage: Configuration.channelCountUsage, completion: nil)
            let result = try parser.parse(args)
            let host = result.get(hostOption) ?? Configuration.defaultHost
            let port = result.get(portOption) ?? Configuration.defaultPort
            let channelCount = result.get(channelCountOption) ?? Configuration.defaultChannelCount
            return Configuration(host: host, port: port, channelCount: channelCount)
        }
    }
    
    let configuration: Configuration
    private(set) var channel: Channel!
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    @discardableResult
    func start(channelInitializer: @escaping () -> RequestChannel) throws -> EventLoopFuture<Void> {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: configuration.channelCount)
        let shutDownGroup = { _ = try? group.syncShutdownGracefully() }
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            
            .childChannelInitializer { channel in
                channel.pipeline.configureHTTPServerPipeline(withErrorHandling: true)
                    .then { (_) -> EventLoopFuture<Void> in
                        do {
                            let requestChannel = channelInitializer()
                            try await(requestChannel.prepare())
                            return channel.pipeline.add(handler: RequestHandler(requestChannel: requestChannel))
                        } catch {
                            return channel.eventLoop.newFailedFuture(error: error)
                        }
                    }
            }
            
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 16)
            .childChannelOption(ChannelOptions.recvAllocator, value: AdaptiveRecvByteBufferAllocator())
        
        do {
            channel = try bootstrap.bind(host: configuration.host, port: configuration.port).wait()
            return channel.closeFuture
                .map(shutDownGroup)
                .mapIfError({ _ in shutDownGroup()})
        } catch {
            shutDownGroup()
            throw error
        }
    }
}
