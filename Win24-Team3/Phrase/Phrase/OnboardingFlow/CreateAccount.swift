//
//  CreateAccount.swift
//  Phrase
//
//  Created by Matthew and Feliciano on 2/19/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateAccount: View {
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false // To toggle password visibility
    @State private var isConfirmPasswordVisible: Bool = false // To toggle password visibility
    @State private var errorMessage: String? // To display any error messages
    @State private var showOnboardingFlow = false
    
    @ObservedObject private var stateManager = StateManager.shared
    
    var body: some View {
        ZStack {
            Color("PhraseGreen")
                .edgesIgnoringSafeArea(.all)
          
            
            VStack(spacing: 30) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .padding(.top, 150)
                    .foregroundColor(.white)
                
                Spacer()
                
                ZStack{
                    Image("CreateAccountVector") // Add the squiggle image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 60)

                }.edgesIgnoringSafeArea(.all)
                    .padding(.bottom, 40)
               
             

                 // Email textfield
                 ZStack {
                     RoundedRectangle(cornerRadius: 5)
                         .fill(.white)
                         .opacity(0.2)
                    
                     SuperTextField( // modified textfield to support colored placeholder text
                        placeholder: Text("Email")
                            .foregroundColor(.white),
                        text: $email
                     )
                     .foregroundColor(.white)
                     .padding(.leading, 10)
                 }
                 .frame(width: 330, height: 35)

                
                // Username textfield
                 ZStack {
                     RoundedRectangle(cornerRadius: 5)
                         .fill(.white)
                         .opacity(0.2)
                    
                     SuperTextField(
                         placeholder: Text("Name")
                             .foregroundColor(.white),
                         text: $name
                     )
                     .foregroundColor(.white)
                     .padding(.leading, 10)
                 }
                 .frame(width: 330, height: 35)
                
                
                // Password textfield
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white)
                        .opacity(0.2)
                    
                    HStack {
                        if isPasswordVisible {
                            SuperTextField(
                                placeholder: Text("Password")
                                    .foregroundColor(.white),
                                text: $password
                            )
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            
                        } else {
                            SuperSecureField(placeholder: Text("Password")
                                .foregroundColor(.white),
                                text: $password
                            )
                            .foregroundColor(.white)
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
     
                
                // Confirm Password textfield
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white)
                        .opacity(0.2)
                    
                    HStack {
                        if isConfirmPasswordVisible {
                            SuperTextField(
                                placeholder: Text("Confirm Password")
                                    .foregroundColor(.white),
                                text: $confirmPassword
                            )
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            
                        } else {
                            SuperSecureField(placeholder: Text("Confirm Password")
                                .foregroundColor(.white),
                                text: $confirmPassword
                            )
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                        }
                        
                        Button(action: {
                            isConfirmPasswordVisible.toggle()
                        }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
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
                
                
                // Sign Up button
                Button(action: {
                    createAccount()
                }) {
                    Text("Sign Up")
                        .foregroundColor(Color("PhraseGreen"))
                        .frame(width: 295)
                        .padding()
                        .background(.white)
                        .cornerRadius(5)
                }
                .frame(height: 50)
                .padding(.top)
                
                Button(action: {
                    stateManager.toCreateAccount = false
                    stateManager.toVisualizeExplain = false
                    stateManager.toWriteExplain = false
                    stateManager.toReflectExplain = false
                    stateManager.showLoginView = true
                }) {
                    Text("Already Have Account?")
                        .foregroundColor(.white)
                }
                
                //NavigationLink(destination:
                                //WriteExplain(), isActive: $stateManager.toWriteExplain) { EmptyView()} // should be two navigation links depending on shouldShowDailyEntry
                NavigationLink(destination: OnboardingFlowView(), isActive: $showOnboardingFlow) {
                    EmptyView()
                }
                
                NavigationLink(destination:
                                LoginPage(), isActive: $stateManager.showLoginView) { EmptyView()} // should be two navigation links depending on shouldShowDailyEntry
            }
            
            
            .padding(.bottom, 150)
            
            .navigationBarBackButtonHidden(true) // Hide back button
            .navigationBarHidden(true) // Hide navigation bar
        }
    }
    
    private func createAccount() {
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return
        }
        
        if name.isEmpty {
            errorMessage = "Please submit a name."
            return
        }
        
        // Create a reference to the Firestore database
        let db = Firestore.firestore()
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating account: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            } else if let user = authResult?.user {
                print("Account created successfully")
                
                // Create a new user document with the user's UID as the document ID
                db.collection("user").document(user.uid).setData([
                    "name": name,
                    "user_id": user.uid, // Use the username provided during account creation
                    "email": email, // Use the email provided during account creation
                ]) { error in
                    if let error = error {
                        print("Error adding user document: \(error.localizedDescription)")
                        errorMessage = "An error occurred. Please try again later."
                    } else {
                        print("User document added successfully")
//                        stateManager.showDailyEntry = true
                        stateManager.toWriteExplain = true
                        stateManager.loginUser(userId: user.uid)
                        showOnboardingFlow = true // Navigate to OnboardingFlowView
                    }
                }
            }
        }
        
    }
}

//#Preview {
//    CreateAccount()
//}
