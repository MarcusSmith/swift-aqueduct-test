//
//  Request.swift
//  Aqueduct
//
//  Created by Marcus Smith on 2/27/19.
//

import Foundation
import NIO
import NIOHTTP1

// TODO: Remove
extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

public class Request: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(head.method) \(head.uri) HEADERS: \(head.headers.map { "\($0.name): \($0.value)" }) - Body: \(buffer.readableBytes) bytes"
    }
    
    public let head: HTTPRequestHead
    var buffer: ByteBuffer
    var trailingHeaders: HTTPHeaders?
    
    init(head: HTTPRequestHead, buffer: ByteBuffer) {
        self.head = head
        self.buffer = buffer
    }
    
    public func decodeBody<T: Decodable>(as type: T.Type) throws -> T {
        guard buffer.readableBytes > 0 else {
            throw "No body"
        }
        
        guard let bytes = buffer.getBytes(at: 0, length: buffer.readableBytes) else {
            throw "No Bytes"
        }
        
        return try JSONDecoder().decode(T.self, from: Data(bytes))
    }
}
