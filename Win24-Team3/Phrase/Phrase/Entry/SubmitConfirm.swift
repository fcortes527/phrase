//
//  SubmitConfirm.swift
//  Phrase
//
//  Created by Melanie Zhou on 2/8/24.
//
//
import Foundation
import SwiftUI

struct SubmitConfirm: View {
    @ObservedObject private var stateManager = StateManager.shared
    var body: some View {
        NavigationStack{
            ZStack {
                Color("PhraseGreen") // Use Color.blue as the background color for the entire screen
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    Text(getToday())
                        .foregroundColor(.white)
                        .font(.system(size: 25))
                    
                    Text("Done")
                        .foregroundColor(.white)
                        .font(.system(size: 50))
                    
                    Image("SubmitVector")
                        .imageScale(.small)
                        .foregroundStyle(.tint)
                    
                }
                .onTapGesture {
                    stateManager.loadPastEntries()
                    stateManager.loadJournals()
                }
                NavigationLink(destination: PastEntries(), isActive: $stateManager.toLoadPastEntries) {
                    EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Apply this modifier here
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures correct style on all devices
    }
}
