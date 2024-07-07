//  Reflect Onboarding.swift
//  Phrase
//
//  Created by Matthew Yekell on 2/4/24.
//
import SwiftUI

struct ReflectExplain: View {
    var body: some View {
        ZStack {
            Color("PhraseGreen")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Image("journal icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom)
                
                Text("Reflect")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                Text("Organize and sort past “phrases” into different journals.")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 35)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
