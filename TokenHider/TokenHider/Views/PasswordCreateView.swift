//
//  PasswordCreateView.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//

import SwiftUI

struct PasswordCreateView: View {
    @State var password = ""
    @State var passName = ""
    @State var passBody = ""
    @State var secret = ""
    @State var success = false
    var body: some View {
        Text("Enter a Name For Your Password")
        TextField("Name", text: $passName)
            .border(.black)
            .textInputAutocapitalization(.never)

        Text("Enter Your Password")
        SecureField("Create Password", text: $password)
            .border(.black)
            .textInputAutocapitalization(.never)

        Text("Enter any other info")
        TextEditor(text: $passBody)
            .border(.blue)
            .textInputAutocapitalization(.never)
        Spacer()
        SecureField("Enter Your Secret", text: $secret)
            .border(.black)
            .textInputAutocapitalization(.never)

        Spacer()
        VStack {
            Button(action: {
                createPassword()
                
            })
                {
                    Text("Create")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.green)
                        .cornerRadius(15.0)
                }
                .alert("Password Successfully Added", isPresented: $success) {
                    Button("OK", role: .cancel) {}
                }
        }
    }
    
    
    func createPassword() { //uses end to end encryption simulator function to ensure passwords have an extra layer of security 
        success = false
        do {
            let symmetric = Secret().getSymmetricKey(forKey: "symmetricPasswordKey")
            
            let encryptedTitle = try Secret().endToEndEncrypt(text: passName, symmetricKey: symmetric, secret: secret)

            let encryptedPassword = try Secret().endToEndEncrypt(text: password, symmetricKey: symmetric, secret: secret)
            let encryptedBody = try Secret().endToEndEncrypt(text: passBody, symmetricKey: symmetric, secret: secret)
            let passwordStruct = Password(title: encryptedTitle, password: encryptedPassword, body: encryptedBody)
            print(passwordStruct.title)
            let encoder = JSONEncoder()
            guard UserDefaults.standard.data(forKey: "allPasswords") != nil else {
                let data2 = try encoder.encode([passwordStruct])
                print(String(data: data2, encoding: .utf8)!)
                UserDefaults.standard.set(data2, forKey: "allPasswords")
                success = true
                return
            }
            let givenData = UserDefaults.standard.data(forKey: "allPasswords")
            
            let decoder = JSONDecoder()
            var array = try decoder.decode([Password].self, from: givenData!)
            array.append(passwordStruct)
            let encodedArray = try encoder.encode(array)
            UserDefaults.standard.set(encodedArray, forKey: "allPasswords")
            success = true
        } catch { print(error) }
    }
}

struct PasswordCreateView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordCreateView()
    }
}
