//
//  Write Onboarding.swift
//  Phrase
//
//  Created by Matthew Yekell on 2/4/24.
//
/*
 To do: import the font and make it work
 
 We got rid of the line at the top because it looks cluttered and highkey ugly */

import SwiftUI

struct WriteExplain: View {
    var body: some View {
        ZStack {
            Color("PhraseGreen")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Image("Write Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                
                Text("Write")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                Text("Write and post a one-sentence “phrase” about your day.")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true) // Hide back button
        .navigationBarHidden(true) // Hide navigation bar
    }
}
