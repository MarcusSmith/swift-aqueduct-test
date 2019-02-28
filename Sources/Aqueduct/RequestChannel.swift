//
//  RequestChannel.swift
//  Aqueduct
//
//  Created by Marcus Smith on 2/24/19.
//

import Foundation

public protocol RequestChannel {
    func prepare(completion: (Error?) -> Void)
}

public extension RequestChannel {
    func prepare(completion: (Error?) -> Void) {
        completion(nil)
    }
}
