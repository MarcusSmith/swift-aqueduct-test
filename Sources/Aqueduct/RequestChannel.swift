//
//  RequestChannel.swift
//  Aqueduct
//
//  Created by Marcus Smith on 2/24/19.
//

import Foundation
import Promises

public protocol RequestChannel {
    func prepare() -> Promise<Void>
    func transform(_ error: Error) -> Response
    var entryPoint: Controller { get }
}

public extension RequestChannel {
    func prepare() -> Promise<Void> {
        return Promise(())
    }
    
    func transform(_ error: Error) -> Response {
        if let statusError = error as? StatusCodeError {
            return Response(statusCode: statusError.statusCode, value: statusError.localizedDescription)
        }
        
        return Response(statusCode: 500)
    }
}
