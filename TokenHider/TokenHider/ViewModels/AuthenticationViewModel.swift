//
//  AuthenticationViewModel.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//
import Foundation
import SwiftUI
class AuthenticationViewModel: ObservableObject {
    
    enum SignInState {
        case authIsValid
        case signedIn
        case signedOutRegister
        case signedOutLogin
        case welcomeScreen

    }
    @Published var state: SignInState?
    @Published private var authState = false
    @Published var switchHome1 = false
    @Published var switchHome = false
    @Published var switchPasscodeCreate = false
    @Published private var codeCreate = ""
    @Published private var codeExisting = ""
    @Published private var createText = ""
    @Published private var existingText = ""
    
    //init() {state = .welcomeScreen}
    public func genKey() -> [UInt8] {
        let key = Secret().generateKey()
        return Secret().obfuscateKey(key: key)
    }
    func movetoLogin(){state = .signedOutLogin}
    func movetoRegister(){state = .signedOutRegister}

}
