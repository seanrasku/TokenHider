//
//  Private.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//

import Foundation
import SwiftUI
import CryptoKit

struct Private: Codable, Identifiable {
    let id = UUID()
    let privateKey: [UInt8]
}
