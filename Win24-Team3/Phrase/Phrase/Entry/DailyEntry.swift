//
//  Entry.swift
//  Phrase
//
//  Created by Melanie Zhou on 2/7/24.
//

import Foundation
import SwiftUI

struct DailyEntry: View {
    
    @State private var messageText: String = ""
    @ObservedObject private var stateManager = StateManager.shared
    
    @State private var isExpanded = false
    
    var body: some View {
        
        VStack(spacing:20) {
            ZStack {
                Color("PhraseGreen")
                    .edgesIgnoringSafeArea(.top) // Extend the color to the top edge of the screen
                    .frame(height: 60)
                
                Text(getToday())
                    .font(.headline)
                    .foregroundColor(.white)
            }
            VStack(spacing: 10) {
                // Text Editor field
                PlaceholderTextView(placeholder: "What's on your mind?", text: $messageText)
                    .frame( maxWidth: .infinity, minHeight: CGFloat(400), maxHeight:  CGFloat(600))
                
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                
                
                
                List {
                    DisclosureGroup("Need some inspiration?", isExpanded: $isExpanded) {
                        ForEach(PROMPTS, id: \.self) { item in
                            Text(item)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                        
                // Submit button
                Button(action: {
                    submitEntry()
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PhraseGreen"))
                        .cornerRadius(10)
                }
                
                .padding()
                // Invisible NavigationLink triggered by `shouldNavigate`
                NavigationLink(destination:
                                SubmitConfirm(), isActive: $stateManager.congratsScreen) { EmptyView()}
                
            }
            .navigationBarBackButtonHidden(true) // Apply this modifier here
            .navigationViewStyle(StackNavigationViewStyle()) // Ensures correct style on all devices
//            .navigationViewStyle(.stack)
        }
    }
    
    func submitEntry() {
        guard !messageText.isEmpty else {
            return
        }
        
        @ObservedObject var model = ViewModel()
        // print("Entry to submit: \(messageText)")
        model.createEntry(entry_text: messageText, user_id: stateManager.userId)
        StateManager.shared.submittedToday()
        StateManager.shared.submitConfirmation()
    }
    
    struct PlaceholderTextView: View {
        let placeholder: String
        @Binding var text: String
        var body: some View {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                        .padding(.top, 8)
                }
                TextEditor(text: $text)
                    .padding(4)
                    .opacity(text.isEmpty ? 0.25 : 1)
            }
        }
    }
    
}
