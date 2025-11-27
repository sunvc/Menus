//
//  PeacockProtocol.swift
//  PeacockMenus
//
//  Created by He Cho on 2024/9/6.
//

import Defaults
import Foundation
import SwiftUI

let ISPAD = UIDevice.current.userInterfaceIdiom == .pad

extension Defaults.Keys {
    static let deviceToken = Key<String>("deviceToken", "")
    static let id = Key<String>("deviceID", "")
}

enum VipCardImage: String, CaseIterable {
    case card0
    case card1
    case card2
    case card3
    case card4
    case card5

    var string: String { rawValue }
}
