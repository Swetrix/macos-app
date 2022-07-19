//
//  ContentView.swift
//  macosapp
//
//  Created by Andrii on 19.7.2022.
//

import SwiftUI

let apiURLPrefix = "https://api.swetrix.com"

struct ContentView: View {
    var body: some View {
        LoginView()
            .padding()
            .frame(minWidth: 1200, minHeight: 800)
    }
}

struct AuthResponseModel: Decodable {
    let access_token: String
}

// Used for storing key: value into a secure database
final class KeychainHelper {
    static let standard = KeychainHelper()
    private init() {}
    
    func save(_ data: Data, service: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "swetrix",
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        // In case if item exists, we update it
        if status == errSecDuplicateItem {
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: "swetrix",
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
            
            let attributesToUpdate = [kSecValueData: data] as CFDictionary
            
            SecItemUpdate(query, attributesToUpdate)
        }
        
        if status != errSecSuccess {
            // todo: alert a token saving error
        }
    }
    
    func save(_ data: String, service: String) {
        return save(Data(data.utf8), service: service)
    }
    
    func read(service: String) -> Data? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: "swetrix",
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return (result as? Data)
    }
    
    func read(service: String) -> String {
        let data: Data? = read(service: service)
        return String(data: data!, encoding: .utf8)!
    }
}

struct MainView: View {
    var body: some View {
        VStack() {
            Text("Swetrix main menu")
        }
        .frame(width: 600)
    };
}

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    let verticalPaddingForForm = 40
    
    func authenticate() async {
        let endpoint = "/auth/login"
        guard let url = URL(string: apiURLPrefix + endpoint) else { return }
        
        let body: [String: Any] = ["email": email, "password": password]
        
        let processedBody = try! JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = processedBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.upload(for: request, from: processedBody)
            if let httpResponse = response as? HTTPURLResponse {
                // check if login failed due to incorrect credentials
                if httpResponse.statusCode != 201 {
                    alertMessage = "Email or password is incorrect"
                    showingAlert = true
                    password = ""
                    return
                }
            } else {
                return
            }
            
            let decoded = try JSONDecoder().decode(AuthResponseModel.self, from: data)
            alertMessage = decoded.access_token
            showingAlert = true
            KeychainHelper.standard.save(data, service: "access_token")
        } catch (let error) {
            alertMessage = "Authentication failed: " + error.localizedDescription
            showingAlert = true
        }
    }
    
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
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .frame(height: 30)
                        SecureField("Password", text: $password)
                            .padding(.horizontal, 30).padding(.top, 20)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .textContentType(.password)
                    }
                    .padding([.top])
                    
                    Button("Sign in") {
                        Task {
                            await authenticate()
                        }
                    }
                    .padding(10)
                    .font(.system(size: 20))
                    .cornerRadius(10)
                    .padding(.vertical)
                    .alert(alertMessage, isPresented: $showingAlert) {
                        Button("OK", role: .cancel) { }
                    }
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
