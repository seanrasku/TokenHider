//
//  InitialViewModel.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//

import Foundation
import SwiftUI
class InitialViewModel: ObservableObject {
    enum secretState {
        case onInit
        case newSecret
        case existingSecret
    }
    @Published var token = false
    @Published var switchViews = false
    @Published var state: secretState = .onInit

    init() {
        switchViews = false
        token = false
        do { // create private key, set symmetric key before login screen so login can succeed
            let check = UserDefaults.standard.bool(forKey: "symLoginKey")
            if check == false {
                token = true
                let rawKey = Secret().generateKey()
                let encryptedKey = Secret().obfuscateKey(key: rawKey)
                let data = Secret().keyToJSON(key: encryptedKey)
                UserDefaults.standard.set(data, forKey: "privateKey")
                Secret().setSymmetricKey(objForKey: "symmetricLoginKey", boolForKey: "symLoginKey")
            }
            else {
                print("Symmetric Key Present")
                token = false
                switchViews = true
            }
        } catch { print(error) }
        
    }
    
    func moveCreate() {
        self.state = .newSecret
    }
    func moveExisting() {
        self.state = .existingSecret
    }
}
