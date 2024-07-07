//
//  ProfilePage.swift
//  Phrase
//
//  Created by Feliciano Cortes on 2/28/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfilePage: View {
    @ObservedObject private var viewModel = StateManager.model
    @ObservedObject private var stateManager = StateManager.shared
    @State private var new_name: String = StateManager.model.user.name
    @State private var new_email: String = "melanie's to do email"
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isEditMode = false
    @State private var showAlert = false
    
    func logout() {
        stateManager.logoutUser()
    }
    
    func updateEditMode() {
        isEditMode = false
        self.selectedImage = nil
    }
    
    func reloadUser() {
        viewModel.reloadUser(callback: updateEditMode);
    }
    
    func uploadImageAndSaveURL() {
        if let image = selectedImage {
            guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
            let imageName = UUID().uuidString
            
            let db = Firestore.firestore()
            let storageRef = db.collection("images").document(imageName)
            
            storageRef.setData(["imageData": imageData, "user_id": stateManager.userId]) { error in
                if let error = error {
                    print("Error saving image data: \(error.localizedDescription)")
                    isEditMode = false
                    return
                }
                print("Image data saved successfully!")
                viewModel.updateProfilePic(collection: "user", lookup_field: "user_id" ,supplied_field: stateManager.userId, field_to_change: "profile_img", new_value: imageData, callback: reloadUser)
            }
        }
    }
    
    func deleteAndUploadImageAndSaveURL() {
        viewModel.deleteImageUser(userId: stateManager.userId, callback: uploadImageAndSaveURL)
    }
    
    var body: some View {
        VStack() {
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.medium)
                .padding(.top, 40)
                .foregroundColor(.phraseGreen)
            
            Button(action: {
                if isEditMode {
                    self.isImagePickerPresented = true
                }
            }) {
                if let image = selectedImage, isEditMode {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                } else if let imageData = viewModel.user.profile_img, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                } else {
                    Image("profilePicIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
            }
            .frame(width: 150, height: 150)
            .padding()
            
            // Display user's name
            VStack() {
                if isEditMode {
                    TextField("First Last", text: $new_name)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 2)
                    
                } else {
                    Text(viewModel.user.name)
                        .font(.largeTitle)
                        .foregroundColor(.phraseBlue)
                        .fontWeight(.heavy)
                }
            }
            .padding(.bottom, 60)
            
            HStack() {
                Text("Email")
                    .bold()
                    .foregroundColor(.phraseGreen)
                Spacer()
            }
            .padding(.bottom, -5)
            
            
            VStack() { // display user's email
                Text(getCurrentUserEmail() ?? "No email")
                    .padding()
                    .frame(width: 315, height: 40, alignment: .leading )
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(4)
                
            
                
            }
            
            Spacer()
            
            /*  No editing password for now. To Do with firebase auth later on */
            //            // Password title
            //            HStack() {
            //                Text("Password")
            //                    .font(.title2)
            //                    .foregroundColor(.phraseGreen)
            //                Spacer()
            //            }
            //            .padding(.top)
            //            .padding(.bottom, -5)
            //
            //            // Password textfield
            //            if isEditMode {
            //                TextField("Password", text: $password)
            //                    .textFieldStyle(RoundedBorderTextFieldStyle())
            //                    .padding(.bottom, 20)
            //            } else {
            //                ZStack {
            //                    RoundedRectangle(cornerRadius: 5)
            //                        .fill(.gray)
            //                        .opacity(0.3)
            //                        .frame(height: 40)
            //                    HStack {
            //                        // TO DO: Replace with logged in user's data (Firebase stuff)
            //                        Text("my_password")
            //                            .opacity(0.6)
            //                            .padding(.leading)
            //                        Spacer()
            //                    }
            //                }
            //            }
            
            if isEditMode {
                
                // kinda crusty control flow to ensure reload user user only called once
                Button(action: {
                    if let image = selectedImage {
                        if !new_name.isEmpty && new_name != viewModel.user.name {
                            viewModel.writeData(collection: "user", lookup_field: "user_id", supplied_field: stateManager.userId, field_to_change: "name", new_value: new_name) {
                                deleteAndUploadImageAndSaveURL()
                            }
                        } else {
                            deleteAndUploadImageAndSaveURL()
                        }
                    }
                    
                    else if (!new_name.isEmpty && new_name != viewModel.user.name) {
                        viewModel.writeData(collection: "user", lookup_field: "user_id" ,supplied_field: stateManager.userId, field_to_change: "name", new_value: new_name, callback: reloadUser)
                    }
                    else {
                        isEditMode = false
                    }
                    
                }) {
                    Text("Confirm")
                        .frame(width: 180, height: 40)
                        .background(.phraseGreen)
                        .foregroundColor(.white)
                        .cornerRadius(5)

                } .padding(.top, 20)
                
                Button(action: {
                    showAlert = true
//
                }) {
                    Text("Delete Account")
                        .frame(width: 180, height: 40)
                        .background(.white)
                        .foregroundColor(.phraseGreen)
                        .cornerRadius(5)
                }.padding(.top, 40)
                    .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("You are about to delete your account"),
                                    primaryButton: .default(Text("Yes"), action: {
                                        viewModel.deleteUserAndAllStorage(user_id: stateManager.userId, callback: logout)
                                        print("Account successfully deleted")
                                    }),
                                    secondaryButton: .cancel(Text("No"))
                                )
                            }
               
                
            } else {
                Button(action: {
                    isEditMode = !isEditMode   // Toggle the edit mode
                }) {
                    Text("Edit")
                        .foregroundColor(.phraseGreen)
                        .font(.title2)
                        .padding()
                }
                
                // Logout Button
                Button(action: {
                    stateManager.logoutUser()
                    
                }) {
                    Text("Logout")
                        .frame(width: 180, height: 40)
                        .background(.phraseGreen)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            
            // TODO: front end design
            // TODO: maybe pop-up (e.g. "are you sure? this cannot be undone...")
 
        }
        .padding(.horizontal, 40)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: self.$selectedImage)
                .onDisappear {
                    // Ensure UI updates on the main thread
                    DispatchQueue.main.async {
                        self.isImagePickerPresented = false
                    }
                }
        }
        
        VStack {
            Spacer()
            NavBar()
                .navigationBarHidden(true)
        }
    }
}

func getCurrentUserEmail() -> String? {
       return Auth.auth().currentUser?.email
   }


