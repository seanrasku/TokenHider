//
//  HomeView.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//

import SwiftUI
import Crypto

struct HomeView: View {
    @State var confirmedPasscode = ""
    @State var switchToCreate = false
    @State var switchToView = false
    @State var authState = false

  var body: some View {
    
      ZStack{
          
              VStack {
                  Text("Create a password first, then use created passcode from create screen to view. Use the same secret for all passwords, or only those with the correct secret will show up")
                  NavigationLink(destination: PasswordCreateView(), isActive: $switchToCreate) {
                      EmptyView()
                  }
                  
                  
                  Button (action: {
                      checkSymmetric()
                      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                          self.switchToCreate = true
                      }
                      
                  }){
                      Text("Create New Password")
                          .font(.headline)
                          .padding()
                          .foregroundColor(.white)
                          .frame(width: 250, height: 50)
                          .background(Color.blue)
                          .cornerRadius(15.0)
                  }
                  
                  Text("Enter Passcode To View")
                      .bold()
                  SecureField("Enter", text: $confirmedPasscode)
                      .border(.secondary)
                      .textInputAutocapitalization(.never)
                  Spacer()
                  
                  Button (action: {
                      checkSymmetric()
                      authenticatePassword()
                      if authState == true {
                          DispatchQueue.main.asyncAfter(deadline: .now() + 3) { //wait for auth to complete, then set switch to true
                              self.switchToView = true
                          }
                      }
                  }){
                      Text("View My Passwords")
                          .font(.headline)
                          .padding()
                          .foregroundColor(.white)
                          .frame(width: 250, height: 50)
                          .background(Color.blue)
                          .cornerRadius(15.0)
                  }
                  
                  NavigationLink(destination: PasswordDisplayView(passed: confirmedPasscode), isActive: $switchToView) {
                      EmptyView()
                  }
                  Spacer()
            }
      }
  }
    func checkSymmetric() {
        let check = UserDefaults.standard.bool(forKey: "symPasswordKey")
        if check == false {
            Secret().setSymmetricKey(objForKey: "symmetricPasswordKey", boolForKey: "symPasswordKey")
        }
    }
    
    func authenticatePassword() {
        switchToView = false
        switchToView = false
        authState = false
        if confirmedPasscode == "" {
            print("no passcode entered")
            return
        }
        authState = true
        
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
