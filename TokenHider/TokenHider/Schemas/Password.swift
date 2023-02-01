//
//  Password.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//

import Foundation
import SwiftUI

struct Password: Codable, Identifiable {
    let id = UUID()
    let title: String
    let password: String
    let body: String
}
