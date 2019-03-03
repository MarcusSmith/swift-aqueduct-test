//
//  Application.swift
//  aqueduct
//
//  Created by Marcus Smith on 2/24/19.
//

import Foundation
import Promises
import NIO

public protocol ApplicationProtocol {
    var configuration: Server.Configuration { get }
    func listen()
}

public protocol ApplicationDelegate: Decodable {
    func applicationWillStart(application: ApplicationProtocol)
    func applicationDidStart(application: ApplicationProtocol)
    func applicationFailedToStart(application: ApplicationProtocol, error: Error)
    func applicationStopped(application: ApplicationProtocol, error: Error?)
    func prepare() -> Promise<Void>
    func generateRequestChannel() -> () -> RequestChannel
}

public extension ApplicationDelegate {
    func applicationWillStart(application: ApplicationProtocol) {
        print("Application will start")
    }
    
    func applicationDidStart(application: ApplicationProtocol) {
        print("Listening on \(application.configuration.host) port \(application.configuration.port)")
    }
    
    func applicationFailedToStart(application: ApplicationProtocol, error: Error) {
        print("Application failed to start:", error.localizedDescription)
        exit(1)
    }
    
    func applicationStopped(application: ApplicationProtocol, error: Error?) {
        if let error = error {
            print("Application failed:", error.localizedDescription)
            exit(1)
        } else {
            print("Application stopped")
            exit(0)
        }
    }
    
    func prepare() -> Promise<Void> {
        return Promise<Void>(())
    }
}

public class Application<Delegate: ApplicationDelegate>: ApplicationProtocol {
    public let delegate: Delegate
    public let configuration: Server.Configuration
    private var server: Server!
    
    public init(processInfo: ProcessInfo) throws {
        configuration = try Server.Configuration.from(Array(processInfo.arguments.dropFirst()))
        let environment = EnvironmentDecoder(processInfo.environment)
        delegate = try Delegate(from: environment)
    }
    
    public func listen() {
        delegate.applicationWillStart(application: self)
        
        server = Server(configuration: configuration)
        
        do {
            try await(delegate.prepare())
            try server.start(channelInitializer: self.delegate.generateRequestChannel())
            delegate.applicationDidStart(application: self)
        } catch {
            self.delegate.applicationFailedToStart(application: self, error: error)
        }
        
        do {
            try server.channel.closeFuture.wait()
            delegate.applicationStopped(application: self, error: nil)
        } catch {
            delegate.applicationStopped(application: self, error: error)
        }
    }
}
