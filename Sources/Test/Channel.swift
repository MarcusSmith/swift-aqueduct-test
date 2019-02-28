//
//  Channel.swift
//  Aqueduct
//
//  Created by Marcus Smith on 2/24/19.
//

import Foundation
import Aqueduct

struct TestModel: Decodable, CustomDebugStringConvertible {
    var debugDescription: String {
        return "TestModel: ID: \(id), name: \(name)"
    }
    
    let id: Int
    let name: String
}

class Channel: RequestChannel {
    init() { }
    func handleRequest(request: Request) { // TODO: How to handle responses and errors
        print("Got a request")
        print(request)
        print("Got body")
        print(try! request.decodeBody(as: TestModel.self))
    }
}
