//
//  ContentView.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//

import SwiftUI
import Crypto

struct ContentView: View {
    @State private var authState = false
    @State var switchHome1 = false
    @State var switchHome = false
    @State var switchPasscodeCreate = false
    @State private var codeCreate = ""
    @State private var codeExisting = ""
    @State private var createText = ""
    @State private var existingText = ""
    var body: some View {
            ZStack {
                VStack {
                    NavigationLink(destination: HomeView(), isActive: $switchPasscodeCreate) {
                        EmptyView()
                    }
                    
                    Text("New Login Token (minimum length of 8): ")
                    SecureField("Create Token", text: $codeCreate)
                        .padding()
                        .textInputAutocapitalization(.never)
                    Spacer()
                    Text(createText)
                    Button (action: {
                        createLoginSecret()
                        if authState == true {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                switchPasscodeCreate = true
                            }
                        }
                    }){
                        Text("Enter")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.red)
                            .cornerRadius(15.0)
                    }
                    Text(createText)
                    Spacer()
                }
                VStack {
                    Spacer()
                    Text("Existing Login Token: ")
                    NavigationLink(destination: HomeView(), isActive: $switchHome) {
                        EmptyView()
                    }
                    SecureField("Enter Your Token", text: $codeExisting)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(20.0)
                        .textInputAutocapitalization(.never)

                    
                    Button (action: {
                        authenticateLogin()
                        if authState == true {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                switchHome = true
                            }
                        }
                    }){
                        Text("Enter")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(15.0)
                    }
                    Text(existingText)
                }
        }
    }
    func createLoginSecret() {
        if codeCreate.count < 8 {
            return
        }
        authState = false
        switchPasscodeCreate = false
        let check = UserDefaults.standard.bool(forKey: "symLoginKey") //ensure symmetric key was already created, if so then proceed to create login secret
        if check == true {
            do {
                let encryptedKey = Secret().retrieveKeyAsUInt(forKey: "privateKey")
                if encryptedKey == nil {
                    print("ERROR: encrypted key is nil")
                    return
                }
                let stringKey = Secret().keyToJSON(key: encryptedKey)

                UserDefaults.standard.set(stringKey, forKey: "privateKey")

                let symmetric = Secret().getSymmetricKey(forKey: "symmetricLoginKey")


                let encryptedPasscode = try Secret().encryptSecret(text: codeCreate, symmetricKey: symmetric)
                UserDefaults.standard.set(encryptedPasscode, forKey: "loginToken")

                authState = true
                createText = "Token Successfully Created, logging in now..."
            } catch { print(error) }
        }
        else {
            createText = "Token Already Exists, Please Enter in Existing"
        }
    }
    func authenticateLogin() {
        authState = false
        switchHome = false
        let passcode = UserDefaults.standard.string(forKey: "loginToken")
        let sym = Secret().getSymmetricKey(forKey: "symmetricLoginKey")
        if passcode == nil { return }
        let decrypted = Secret().decryptData(text: passcode!, symmetricKey: sym)
        if decrypted == codeExisting { //Compare password to decrypted password from local storage, authenticate if matches
            authState = true
            existingText = "Token Exists! Logging in now..."
        }
        else {
            existingText = "No Token \(codeExisting) exists"
        }



    }
}
