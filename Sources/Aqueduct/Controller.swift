//
//  Controller.swift
//  Aqueduct
//
//  Created by Marcus Smith on 3/2/19.
//

import Foundation
import Promises

public protocol Controller {
    func handle(request: Request) -> Promise<Response>
}
