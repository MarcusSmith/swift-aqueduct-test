//
//  Request.swift
//  Aqueduct
//
//  Created by Marcus Smith on 2/27/19.
//

import Foundation
import NIO
import NIOHTTP1

public class Request: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(head.method) \(head.uri) HEADERS: \(head.headers.map { "\($0.name): \($0.value)" }) - Body: \(body.count) bytes"
    }
    
    public let head: HTTPRequestHead
    public var body: HTTPBody
    var trailingHeaders: HTTPHeaders?
    
    init(head: HTTPRequestHead) {
        self.head = head
        self.body = HTTPBody()
    }
}
