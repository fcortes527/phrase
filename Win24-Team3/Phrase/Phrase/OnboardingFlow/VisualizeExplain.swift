//
//  Visualize Onboarding.swift
//  Phrase
//
//  Created by Matthew Yekell on 2/4/24.
//
import SwiftUI

struct VisualizeExplain: View {
    var body: some View {
        ZStack {
            Color("PhraseGreen")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Image("Visualize Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("Visualize")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                Text("Look back at old “phrases” in your submission history.")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 25)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
