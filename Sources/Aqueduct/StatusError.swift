//
//  StatusError.swift
//  Aqueduct
//
//  Created by Marcus Smith on 3/2/19.
//

import Foundation

public protocol StatusCodeError: Error {
    var statusCode: Int { get }
}

public struct StatusError: StatusCodeError {
    public let statusCode: Int
}
