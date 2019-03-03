//
//  Response.swift
//  Aqueduct
//
//  Created by Marcus Smith on 3/2/19.
//

import Foundation
import NIO
import NIOHTTP1

public class Response {
    public let statusCode: Int
    public var headers: HTTPHeaders
    public var trailingHeaders: HTTPHeaders?
    public var body: HTTPBody
    
    public init(statusCode: Int, headers: HTTPHeaders? = nil, body: HTTPBody = HTTPBody()) {
        self.statusCode = statusCode
        self.headers = headers ?? HTTPHeaders()
        self.headers.add(name: "Content-Type", value: "application/json") // FIXME: Remove this
        self.body = body
    }
    
    public convenience init<T: Encodable>(statusCode: Int, headers: HTTPHeaders? = nil, value: T) {
        do {
            let data: Data
            if let stringValue = value as? String {
                data = stringValue.data(using: .utf8)!
            } else {
                data = try JSONEncoder().encode(value)
            }
            self.init(statusCode: statusCode, headers: headers, body: HTTPBody(data: data))
        } catch {
            self.init(statusCode: 500)
        }
    }
}
