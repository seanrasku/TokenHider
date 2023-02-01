//
//  InitialView.swift
//  TokenHider
//
//  Created by Sean Rasku-Casas on 2/1/23.
//

import SwiftUI

import SwiftUI
import Crypto
struct InitialView: View {
    @EnvironmentObject var viewModel: InitialViewModel
    var body: some View {

        ZStack {
            NavigationView{
                VStack{
                    Text("Welcome To TokenHider!")
                        .padding()
                        .font(.largeTitle)
                    Spacer()

                    NavigationLink(destination: ContentView(), isActive: $viewModel.switchViews){
                        EmptyView()
                    }
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.viewModel.switchViews = true
                        }
                        })
                    {
                    Text("Enter")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.orange)
                        .cornerRadius(15.0)

                    }
                    
                    Spacer()
                }
            }
        }
    }
}

