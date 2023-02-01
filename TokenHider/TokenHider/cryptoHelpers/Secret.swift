//
//  Secret.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//

import SwiftUI
import CryptoKit
import Foundation
import CoreData

struct Secret {

    enum keyState {
        case P256
        case obfuscated
        case deobfuscatedArray
        case deobfuscatedString
        

    }
    
    @State var privKeyState: keyState = .deobfuscatedString
    
    //Generate Private key as string
    func generateAndReturnPrivateKey() -> String {
        let privKey = P256.KeyAgreement.PrivateKey()
        let strKey = exportRawPrivateKey(privKey)
        let encryptedKey = obfuscate(strPK: strKey)
        UserDefaults.standard.set(encryptedKey, forKey: "privateKey")
        privKeyState = .deobfuscatedString
        return encryptedKey.deobfuscateAsString(arr: encryptedKey)
    }
    
    //Generate raw private key
    func generateKey() -> P256.KeyAgreement.PrivateKey{
        return P256.KeyAgreement.PrivateKey()
    }
    
    func getSymmetricKey(forKey: String) -> SymmetricKey {
        let key = UserDefaults.standard.object(forKey: forKey) as! [UInt8]
        let unencryptedString = key.deobfuscateAsString(arr: key)
        let keyData = Data(base64Encoded: unencryptedString)
        if keyData == nil {
            print("error: keyData is nil")
            return SymmetricKey.init(data: Data(base64Encoded: "error")!)
        }
        let data = SymmetricKey.init(data: keyData!)
        return data
    }
    
    func retrieveKeyAsUInt(forKey: String) -> [UInt8] {
        let pStruct = UserDefaults.standard.data(forKey: forKey)
        return JSONtoKey(privateStruct: pStruct!)
    }
    
    //create symmetric key from stored keys
    func setSymmetricKey(objForKey: String, boolForKey: String) {
        do {
            let encryptedKey = retrieveKeyAsUInt(forKey: "privateKey")
            let strRaw = encryptedKey.deobfuscateAsString(arr: encryptedKey)
            let rawKey = try Secret().importRawPrivateKey(strRaw)
            
            let symmetric = try Secret().deriveSymmetricKey(privateKey: rawKey, publicKey: rawKey.publicKey)
            let temp = symmetric.withUnsafeBytes{
                return Data(Array($0))
            }
            let symString = temp.base64EncodedString()
            UserDefaults.standard.set(obfuscate(strPK: symString), forKey: objForKey)
            UserDefaults.standard.set(true, forKey: boolForKey)
        } catch { print(error) }
    }
    //Same functionality as above, but return created symmetric key
    func setSymmetricKeyAndReturn(objForKey: String, boolForKey: String) -> String {
        do {
            let pStruct = UserDefaults.standard.data(forKey: "privateKey")
            let encryptedKey = JSONtoKey(privateStruct: pStruct!)
            let strRaw = encryptedKey.deobfuscateAsString(arr: encryptedKey)
            let rawKey = try Secret().importRawPrivateKey(strRaw)
            
            let symmetric = try Secret().deriveSymmetricKey(privateKey: rawKey, publicKey: rawKey.publicKey)
            let temp = symmetric.withUnsafeBytes{
                return Data(Array($0))
            }
            let symString = temp.base64EncodedString()
            UserDefaults.standard.set(obfuscate(strPK: symString), forKey: objForKey) //converts to [UInt8]
            UserDefaults.standard.set(true, forKey: boolForKey)
            return symString
        } catch { print(error) }
        return "error"
    }
    //Turn private key into unrecognizable UInt8 format for secure storage
    func obfuscateKey(key: P256.KeyAgreement.PrivateKey) -> [UInt8] {
        let strKey = exportRawPrivateKey(key)
        let encryptedKey = obfuscate(strPK: strKey)
        privKeyState = .obfuscated
        return encryptedKey
    }
    
    func getObfuscatedSecret(forKey: String) -> String {
        if forKey == "privateKey" { privKeyState = .obfuscated }
        return UserDefaults.standard.string(forKey: forKey) ?? ""
    }
    
    func getSecret(forKey: String) -> String {
        if forKey == "privateKey" { privKeyState = .deobfuscatedString }
        let key = UserDefaults.standard.string(forKey: forKey) ?? ""
        
        let converted: [UInt8] = [UInt8] (key.data(using: .utf8)!)
        return converted.deobfuscateAsString(arr: converted)
    }
    
    
    func exportRawPrivateKey(_ privateKey: P256.KeyAgreement.PrivateKey) -> String {
        let rawPrivateKey = privateKey.rawRepresentation
        let privateKeyBase64 = rawPrivateKey.base64EncodedString()
        let percentEncodedPrivateKey = privateKeyBase64.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        privKeyState = .deobfuscatedString
        return percentEncodedPrivateKey
    }

    func importRawPrivateKey(_ privateKey: String) throws -> P256.KeyAgreement.PrivateKey {
        let privateKeyBase64 = privateKey.removingPercentEncoding!
        let rawPrivateKey = Data(base64Encoded: privateKeyBase64)!
        privKeyState = .P256
        return try P256.KeyAgreement.PrivateKey(rawRepresentation: rawPrivateKey)
    }
    
    //randomizing function for salt
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()<>?/|}{]["
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    //Get back symmetric key from 2 given keys
    func deriveSymmetricKey(privateKey: P256.KeyAgreement.PrivateKey, publicKey: P256.KeyAgreement.PublicKey) throws -> SymmetricKey {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: randomString(length: 25).data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        
        return symmetricKey
    }
    
    func keyToJSON(key: [UInt8]) -> Data {
        do {
            let privateStruct = Private(privateKey: key)
            let encoder = JSONEncoder()
            let data = try encoder.encode(privateStruct)
            return data
        } catch { print(error) }
        return Data()
    }
    
    func JSONtoKey(privateStruct: Data) -> [UInt8] {
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(Private.self, from: privateStruct)
            return data.privateKey
        } catch { print(error) }
        return [0]
    }
    //Encrypt stored information with secret attached as salt
    func endToEndEncrypt(text: String, symmetricKey: SymmetricKey, secret: String) throws -> String {
        let combined = text + secret
        let textData = combined.data(using: .utf8)!
        
        let encrypted = try AES.GCM.seal(textData, using: symmetricKey)
        return encrypted.combined!.base64EncodedString()
    }

    func encryptSecret(text: String, symmetricKey: SymmetricKey) throws -> String {
        let textData = text.data(using: .utf8)!
        let encrypted = try AES.GCM.seal(textData, using: symmetricKey)
        return encrypted.combined!.base64EncodedString()
    }
    func decryptData(text: String, symmetricKey: SymmetricKey) -> String {
        do {
            guard let data = Data(base64Encoded: text) else {
                return "Could not decode text: \(text)"
            }
            
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            guard let text = String(data: decryptedData, encoding: .utf8) else {
                return "Could not decode data: \(decryptedData)"
            }
            
            return text
        } catch let error {
            return "Error decrypting message: \(error.localizedDescription)"
        }
    }
    
    func obfuscate(strPK: String) -> [UInt8] {
        let converted: [UInt8] = [UInt8] (strPK.data(using: .utf8)!)
        let random: [UInt8] = (0..<converted.count).map { _ in UInt8(arc4random_uniform(256)) }
        let obfuscated: [UInt8] = zip(converted, random).map(^)
        privKeyState = .obfuscated
        return obfuscated + random
    }
    
    func checkArray(arr: [UInt8]) -> Bool {
        let converted: [UInt8] = [UInt8] ("Default".data(using: .utf8)!)

        if arr == converted{
            return true
        }
        return false
    }
}

//Additional functionality where format of keys does not allow for use of above functions
extension Array where Element == UInt8 {
   
    var deobfuscateAsArray: [UInt8] {
        let a = prefix(count/2)
        let b = suffix(count/2)
        return zip(a, b).map(^)
    }
    
    func deobfuscateAsString(arr: [UInt8]) -> String {
        return String(bytes: arr.deobfuscateAsArray, encoding: .utf8)!
    }
}

