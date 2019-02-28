//
//  EnvironmentDecoder.swift
//  Aqueduct
//
//  Created by Marcus Smith on 2/24/19.
//

import Foundation

enum DecodingError: LocalizedError {
    case invalidStructure
    case missingKey(key: CodingKey)
    case invalidType(actual: String, expected: String, key: CodingKey)
    
    var errorDescription: String? {
        switch self {
        case .invalidStructure:
            return "Unable to load environment"
        case .missingKey(let key):
            return "Missing environment key: \(key.stringValue)"
        case .invalidType(_, let expected, let key):
            return "Environment key \(key.stringValue) expected to be type \(expected)"
        }
    }
}

struct EnvironmentDecoder: Decoder {
    let values: [String: String]
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey : Any] = [:]
    
    init(_ values: [String: String], codingPath: [CodingKey] = []) {
        self.values = values
        self.codingPath = codingPath
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(StringKeyedDecodingContainer(values: values))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.invalidStructure
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecodingError.invalidStructure
    }
}

private struct StringKeyedDecodingContainer<K: CodingKey> : KeyedDecodingContainerProtocol {
    let codingPath: [CodingKey] = []
    let values: [String: String]
    
    init(values: [String: String]) {
        self.values = values
    }
    
    var allKeys: [K] {
        return values.keys.compactMap { K(stringValue: $0) }
    }
    
    func contains(_ key: K) -> Bool {
        return values.keys.contains(key.stringValue)
    }
    
    func container(for key: K) -> StringValueContainer {
        return StringValueContainer(value: values[key.stringValue], key: key)
    }
    
    func decodeNil(forKey key: K) throws -> Bool {
        return container(for: key).decodeNil()
    }
    
    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: String.Type, forKey key: K) throws -> String {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        return try container(for: key).decode(type)
    }
    
    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        return try container(for: key).decode(type)
    }
    
    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        let path = codingPath + [key]
        return try T(from: EnvironmentDecoder(values, codingPath: path))
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedDecodingContainer(StringKeyedDecodingContainer<NestedKey>(values: values))
    }
    
    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        let string = try container(for: key).decode(String.self)
        let containers = string.components(separatedBy: ",").map { StringValueContainer(value: $0, key: key) }
        return StringUnkeyedContainer(codingPath: [key], containers: containers)
    }
    
    func superDecoder() throws -> Decoder {
        throw DecodingError.invalidStructure
    }
    
    func superDecoder(forKey key: K) throws -> Decoder {
        throw DecodingError.invalidStructure
    }
}

struct StringUnkeyedContainer: UnkeyedDecodingContainer {
    let codingPath: [CodingKey]
    var containers: [SingleValueDecodingContainer]
    
    private let _count: Int
    var count: Int? {
        return _count
    }
    
    var currentIndex: Int = 0
    var isAtEnd: Bool {
        return currentIndex >= _count
    }
    
    init(codingPath: [CodingKey], containers: [SingleValueDecodingContainer]) {
        self.codingPath = codingPath
        self.containers = containers
        _count = containers.count
    }
    
    mutating func nextContainer() throws -> SingleValueDecodingContainer {
        guard !isAtEnd else {
            throw DecodingError.invalidStructure
        }
        
        let container = containers[currentIndex]
        currentIndex += 1
        return container
    }
    
    
    mutating func decodeNil() throws -> Bool {
        return try nextContainer().decodeNil()
    }
    
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: Double.Type) throws -> Double {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: Float.Type) throws -> Float {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: Int.Type) throws -> Int {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try nextContainer().decode(type)
    }
    
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try nextContainer().decode(type)
    }
    
    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try nextContainer().decode(type)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw DecodingError.invalidStructure
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecodingError.invalidStructure
    }
    
    mutating func superDecoder() throws -> Decoder {
        throw DecodingError.invalidStructure
    }
}

struct StringValueContainer: SingleValueDecodingContainer {
    let value: String?
    let key: CodingKey
    var codingPath: [CodingKey] {
        return [key]
    }
    
    init(value: String?, key: CodingKey) {
        self.value = value
        self.key = key
    }
    
    func unwrappedValue() throws -> String {
        guard let value = value else {
            throw DecodingError.missingKey(key: key)
        }
        
        return value
    }
    
    func decodeNil() -> Bool {
        return value == nil || value == ""
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        guard let v = Bool(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "Bool", key: key)
        }
        
        return v
    }
    
    func decode(_ type: String.Type) throws -> String {
        return try unwrappedValue()
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        guard let v = Double(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "Double", key: key)
        }
        
        return v
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        guard let v = Float(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "Float", key: key)
        }
        
        return v
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        guard let v = Int(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "Int", key: key)
        }
        
        return v
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        guard let v = Int8(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "Int8", key: key)
        }
        
        return v
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        guard let v = Int16(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "Int16", key: key)
        }
        
        return v
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        guard let v = Int32(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "Int32", key: key)
        }
        
        return v
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        guard let v = Int64(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "Int64", key: key)
        }
        
        return v
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        guard let v = UInt(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "UInt", key: key)
        }
        
        return v
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard let v = UInt8(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "UInt8", key: key)
        }
        
        return v
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard let v = UInt16(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "UInt16", key: key)
        }
        
        return v
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard let v = UInt32(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "UInt32", key: key)
        }
        
        return v
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard let v = UInt64(try unwrappedValue()) else {
            throw DecodingError.invalidType(actual: "String", expected: "UInt64", key: key)
        }
        
        return v
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        throw DecodingError.invalidStructure
    }
}
