//
//  AppDelegate.swift
//  aqueduct
//
//  Created by Marcus Smith on 2/24/19.
//

import Foundation
import Aqueduct

class AppDelegate: ApplicationDelegate {
    func generateRequestChannel() -> () -> RequestChannel {
        return { Channel() }
    }
}
