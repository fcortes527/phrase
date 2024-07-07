import SwiftUI
import Firebase
import FirebaseFirestore


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct AddJournalView: View {
    @State private var journalName: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @ObservedObject private var model = StateManager.model
    @ObservedObject private var stateManager = StateManager.shared
    @State private var imageURL: String = ""
    let color = Color("PhraseGreen")
    
    var body: some View {
        VStack {
            ZStack {
                Color("PhraseGreen")
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 20)
            }
            .foregroundColor(.white)
            .accentColor(.white)
            
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Create Journal")
                        .foregroundColor(.white) // Set your desired color here
                        .font(.headline)
                }
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        stateManager.toAddJournal = false
                        stateManager.toJournalScreen = true
                    }) {
                        Text("Back")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                
            }
            
            VStack {
                
                VStack {
                    Text("Add Journal Image (Optional)")
                        .bold()
                        .foregroundColor(color)
                    
                }
                .padding(.top, 20)


                    
                HStack{
                    Spacer()
                    Button(action: {
                        self.isImagePickerPresented = true
                    }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(CGSize(width: 2, height: 4), contentMode: .fill)
                                .frame(height:300)
                                .frame(width:200)
                           
                        } else {
                            Image("SelectionImage")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height:300)
                                .frame(width:300)
                          
                        }
                    }
                   

                    .buttonStyle(PlainButtonStyle())
                    .cornerRadius(10)
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker(selectedImage: self.$selectedImage)
                            .onDisappear {
                                DispatchQueue.main.async {
                                    self.isImagePickerPresented = false
                                }
                            }
                    }
                    Spacer()
                } .padding(.bottom, 40)
                VStack {
                    VStack{
                        Text("Add Journal Label")
                            .bold()
                            .foregroundColor(color)
                            .multilineTextAlignment(.leading)
                    }.padding(.bottom, 20)
                    
                    ZStack{
                        TextField("Enter Journal Name", text: $journalName)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5) // Adjust the corner radius as needed
                                    .stroke(color, lineWidth: 1) // Define border color and line width
                            )
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 22)
                    }
                    .padding(.bottom, 40)
                    
                    Button(action: {
                        // Handle submission of journal name and image here
                        print("Journal Name submitted: \(self.journalName)")
                        uploadImageAndSaveURL()
                        stateManager.toLoadPastEntries = true
                    }) {
                        Text("Submit")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(color)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.white, lineWidth: 2) // Change Color.blue and lineWidth as needed
                            )
                            .padding(.horizontal, 20)
                        
                        
                        
                    }
                }
            }
            Spacer()
        }
        NavigationLink(destination: JournalScreen(), isActive: $stateManager.toJournalScreen) { EmptyView() }
    }
    
    func uploadImageAndSaveURL() {
        
        guard !self.journalName.isEmpty else {
            return
        }
        
        if let image = selectedImage {
            guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
            
            let imageName = UUID().uuidString
            
            let db = Firestore.firestore()
            let storageRef = db.collection("images").document(imageName)
            
            let unique_identifiers = model.generateUniqueIdentifiers(count: 1)
            let journal_id = unique_identifiers[0]
            
            storageRef.setData(["imageData": imageData, "journalName": journalName, "journal_id": journal_id, "user_id": stateManager.userId]) { error in
                if let error = error {
                    print("Error saving image data: \(error.localizedDescription)")
                    return
                }
                print("Image data saved successfully!")
                self.journalName = ""
                self.selectedImage = nil
            }
            model.createJournal(journal_img: imageData, journal_label: self.journalName, user_id: StateManager.shared.userId, journal_id: journal_id)
        } else {
            model.createJournal(journal_img: nil, journal_label: self.journalName, user_id: StateManager.shared.userId)
        }
        self.journalName = ""
        self.selectedImage = nil
        
        stateManager.toJournalScreen = true
        stateManager.toAddJournal = false
        
        model.clearModel()
        stateManager.toLoadJournalScreen = true
    }
}
