//
//  HTTPBody.swift
//  Aqueduct
//
//  Created by Marcus Smith on 3/2/19.
//

import Foundation
import NIO

// TODO: Remove
extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}

public struct HTTPBody {
    public var data: Data?
    public var count: Int {
        return data?.count ?? 0
    }
    public var isEmpty: Bool {
        return count == 0
    }
    
    public init(data: Data? = nil) {
        self.data = data
    }
    
    public mutating func write(_ buffer: ByteBuffer) {
        data = buffer.readableBytes > 0 ? Data(buffer.getBytes(at: 0, length: buffer.readableBytes)!) : nil
    }
    
    public func decode<T: Decodable>(as type: T.Type) throws -> T {
        guard let data = data, data.count > 0 else {
            throw "No body"
        }
        
        // TODO: Use different decoder, or allow customization
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public mutating func encode<T: Encodable>(_ value: T) throws {
        // TODO: Use different encoder, or allow customization
        data = try JSONEncoder().encode(value)
    }
}
