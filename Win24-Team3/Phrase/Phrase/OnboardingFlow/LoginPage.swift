//
//  LoginPage.swift
//  Phrase
//
//  Created by Feliciano on 2/19/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Firebase


struct LoginPage: View {
    @State private var email: String = ""    // State variable to bind to the text field
    @State private var password: String = ""    // State variable to bind to the text field
    @State private var errorMessage: String?
    @State private var isPasswordVisible: Bool = false // To toggle password visibility
    @ObservedObject var stateManager = StateManager.shared
    @ObservedObject var model = StateManager.model
    
    var body: some View {
        let color = Color("PhraseGreen")
        VStack {
            VStack(spacing: 30) {
                
                Text("Login")
                    .font(.largeTitle)
                    .padding(.top, 70)
                    .foregroundColor(color)
                
                Spacer()
                ZStack {
                    Image("LoginVectorTeal") // Add the squiggle image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 60)
      
                }.edgesIgnoringSafeArea(.all)
                    .padding(.bottom, 70)
                
                // Email textfield
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white)
                        .stroke(color, lineWidth: 1)
                    
                    SuperTextField( // modified textfield to support colored placeholder text
                       placeholder: Text("Email")
                           .foregroundColor(.gray),
                       text: $email
                    )
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                }
                .frame(width: 330, height: 35)
                .padding(.bottom, 20)
        
                // Password textfield
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white)
                        .stroke(color, lineWidth: 1)
                    
                    HStack {
                        if isPasswordVisible {
                            SuperTextField(
                                placeholder: Text("Password")
                                    .foregroundColor(.gray),
                                text: $password
                            )
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                            
                        } else {
                            SuperSecureField(placeholder: Text("Password")
                                .foregroundColor(.gray),
                                text: $password
                            )
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                        }
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing)
                    }
                }
                .frame(width: 330, height: 35)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PhraseGreen"))
                        .cornerRadius(10)
                }.padding(.horizontal, 30)
                
                Button(action: {
                    stateManager.toCreateAccount = true
                    stateManager.showLoginView = false
                }) {
                    Text("Create An Account")
                        .foregroundColor(Color("PhraseGreen"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .cornerRadius(5)
                   
                }
                
                NavigationLink(destination:
                                DailyEntry(), isActive: $stateManager.showDailyEntry) { EmptyView()} // should be two navigation links depending on shouldShowDailyEntry
                
                NavigationLink(destination:
                                CreateAccount(), isActive: $stateManager.toCreateAccount) { EmptyView()} // should be two navigation links depending on shouldShowDailyEntry
            }
            .navigationBarBackButtonHidden(true) // Apply this modifier here
            .navigationViewStyle(StackNavigationViewStyle()) // Ensures correct style on all devices
            .padding(.bottom, 150)
        }
    }
    
    private func saveUser() {
        print("saving user")
        stateManager.loginUser(userId: model.user.user_id)
        stateManager.showDailyEntry = true
    }
    
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            } else if let user = authResult?.user {
                print("Login successful")
                model.readDataStr(collection: "user", lookup_field: "user_id", supplied_field: user.uid, callback: saveUser)
            }
        }
    }
}


