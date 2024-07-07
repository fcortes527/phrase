//
//  NavBar.swift
//  Phrase
//
//  Created by Melanie Zhou on 2/27/24.
//

import SwiftUI

struct NavBar: View {
    let color = Color("PhraseGreen")
    @ObservedObject private var stateManager = StateManager.shared
    var body: some View {
        HStack {
            
            // First Button as NavigationLink
            NavigationLink(destination: JournalScreen()) {
                Image("journal icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            Spacer()
            
            NavigationLink(destination: PastEntries()) {
                Image("entry icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            
            Spacer()
            
            NavigationLink(destination: ProfilePage()) {
                Image("Profile icon") // TODO: replace
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
        }
        
        
        .frame(maxWidth: .infinity)
        .padding(.leading, 50)
        .padding(.trailing, 50)
        .padding(.top, 10)
        .background(color)
        .edgesIgnoringSafeArea(.bottom) 
    }
}
