//
//  ContentView.swift
//  macosapp
//
//  Created by Andrii on 19.7.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LoginView()
            .padding()
            .frame(minWidth: 1200, minHeight: 800)
    }
}

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    let verticalPaddingForForm = 40
    
    var body: some View {
        ZStack() {
            VStack(spacing:15) {
                Image("BlueLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100.0)
                    .padding(15)

                VStack(spacing: CGFloat(verticalPaddingForForm)) {
                    VStack {
                        TextField("Email", text: $email)
                            .padding(.horizontal, 30).padding(.top, 20)
                        SecureField("Password", text: $password)
                            .padding(.horizontal, 30).padding(.top, 20)
                        
                    }
                    .padding([.top])
                    
                    Button(action: {}) {
                        Text("Sign in")
                            .padding()
                            .font(.system(size: 20))
                    }
                    .cornerRadius(10)
                    .padding(.vertical)
                }
                .frame(width: 600)
            }
        }
    };
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
