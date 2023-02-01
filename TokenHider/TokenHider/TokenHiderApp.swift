//
//  TokenHiderApp.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//

import SwiftUI
import Foundation
import CryptoKit
@main
struct TokenHiderApp: App {

    @StateObject var initial = InitialViewModel()
    var body: some Scene {
        WindowGroup {
            InitialView()
                .environmentObject(initial)
        }
    }
}
