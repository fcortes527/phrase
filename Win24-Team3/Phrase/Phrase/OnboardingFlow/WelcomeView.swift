import SwiftUI

struct WelcomeView: View {
    @ObservedObject private var stateManager = StateManager.shared
    
    var body: some View {
        let color = Color("PhraseGreen")
        ZStack {
            Color("PhraseGreen")
                .edgesIgnoringSafeArea(.all)
            
            Image("Welcome Screen Squiggle") // Add the squiggle image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y: 50)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Phrase")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                    
                    Text("One sentence journal a day")
                        .font(.system(size:20))
                        .foregroundColor(.white)
                }
                .frame(width: 350, alignment: .leading)
                .padding(.bottom)
                
                // Login Button
                Button(action: {
                    stateManager.toWelcomeView = false
                    stateManager.showLoginView = true
                }) {
                    Text("Login")
                        .foregroundColor(color)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .cornerRadius(6)
                }
                
                // Sign Up Button
                Button(action: {
                    stateManager.toWelcomeView = false
//                    stateManager.toWriteExplain = true
                    stateManager.toCreateAccount = true
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(color)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white, lineWidth: 2) // Change Color.blue and lineWidth as needed
                        )
                }
                
                NavigationLink(destination:
                                LoginPage(), isActive: $stateManager.showLoginView) { EmptyView()}
                
                NavigationLink(destination:
                                CreateAccount(), isActive: $stateManager.toCreateAccount) { EmptyView()}
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20) // Add 20 points of padding at the bottom of the VStack
            
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
}
