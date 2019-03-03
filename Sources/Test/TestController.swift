//
//  TestController.swift
//  Aqueduct
//
//  Created by Marcus Smith on 3/2/19.
//

import Foundation
import Aqueduct
import Promises

struct TestModel: Codable, CustomDebugStringConvertible {
    var debugDescription: String {
        return "TestModel: ID: \(id), name: \(name)"
    }
    
    let id: Int
    let name: String
}

class TestController: Controller {
    func handle(request: Request) -> Promise<Response> {
        return Promise(on: .global()) { () -> Response in
            let input = try request.body.decode(as: TestModel.self)
            return Response(statusCode: 200, value: input)
        }
    }
}
