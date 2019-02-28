//
//  Application.swift
//  aqueduct
//
//  Created by Marcus Smith on 2/24/19.
//

import Foundation
import NIO

public protocol ApplicationProtocol {
    var configuration: Server.Configuration { get }
    func listen()
}

public protocol ApplicationDelegate: Decodable {
    func applicationWillStart(application: ApplicationProtocol)
    func applicationDidStart(application: ApplicationProtocol)
    func applicationFailedToStart(application: ApplicationProtocol, error: Error)
    func applicationStopped(application: ApplicationProtocol)
    func prepare(completion: (Error?) -> Void)
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
        print("Application failed:", error.localizedDescription)
        exit(1)
    }
    
    func applicationStopped(application: ApplicationProtocol) {
        print("Application stopped")
        exit(0)
    }
    
    func prepare(completion: (Error?) -> Void) {
        completion(nil)
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
    
    // TODO: Return a Future?
    public func listen() {
        delegate.applicationWillStart(application: self)
        
        server = Server(configuration: configuration)
        
        delegate.prepare { (preparationError) in
            do {
                if let error = preparationError {
                    throw error
                }
                
                try server.start(channelInitializer: delegate.generateRequestChannel())
                delegate.applicationDidStart(application: self)
                try server.channel.closeFuture.wait()
                self.delegate.applicationStopped(application: self)
            } catch {
                delegate.applicationFailedToStart(application: self, error: error)
            }
        }
    }
}
