//
//  PasswordDisplayView.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//
import SwiftUI

struct PasswordDisplayView: View {
    @State var passed: String
    
    var body: some View {
        Text("My Passwords")
        Spacer()
        List(getPasswordList()) { p in
            passwordView(password: unencryptStruct(encrypted: p))
        }
    }
    func unencryptStruct(encrypted: Password) -> Password {
        print("ENCRYPTED")
        print(encrypted)
        let symmetric = Secret().getSymmetricKey(forKey: "symmetricPasswordKey")
        let title = Secret().decryptData(text: encrypted.title, symmetricKey: symmetric)
        let password = Secret().decryptData(text: encrypted.password, symmetricKey: symmetric)
        let body = Secret().decryptData(text: encrypted.body, symmetricKey: symmetric)
        
        let unencrypted = confirmDecrypt(title: title, password: password, body: body)
        print("UNENCRYPTED")
        print(unencrypted)
        return unencrypted
    }
    func getPasswordList() -> [Password] {
        let check = UserDefaults.standard.data(forKey: "allPasswords")
        if (check == nil) {
            print("EMPTY OR NIL")
            return [Password]()
        }
        if let passwordStruct = UserDefaults.standard.data(forKey: "allPasswords") {
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode([Password].self, from: passwordStruct)
                return data
            } catch { print(error) }
        }
        return [Password]()
    }
    
    func confirmDecrypt(title: String, password: String, body: String) -> Password {
        let passcodeLength = passed.count
        let titleLength = title.count
        let passwordLength = password.count
        let bodyLength = body.count
        if title.suffix(passcodeLength) == passed {
            if password.suffix(passcodeLength) == passed {
                if body.suffix(passcodeLength) == passed {
                    let t = String(title.prefix(titleLength - passcodeLength))
                    let p = String(password.prefix(passwordLength - passcodeLength))
                    let b = String(body.prefix(bodyLength - passcodeLength))
                    return Password(title: t, password: p, body: b)
                }
            }
        }
        return Password(title: "Cannot Decrypt, Passcode Incorrect", password: "Cannot Decrypt, Passcode Incorrect", body: "Cannot Decrypt, Passcode Incorrect")
    }
}


struct passwordView: View {
    var password: Password
    
    var body: some View {
        Text("Password Title: \(password.title)")
        Text("Password: \(password.password)")
        Text("Password Info: \(password.body)")
        Spacer()
    }
    
    
}


//struct PasswordDisplayView_Previews: PreviewProvider {
//    static var previews: some View {
//        PasswordDisplayView()
//    }
//}
