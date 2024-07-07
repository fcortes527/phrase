//
//  OnboardingFlowView.swift
//  Phrase
// idk if this is the implementation we want, but we can do it?
//
//  Created by Matthew Yekell on 2/4/24.
//

import SwiftUI

struct CustomPageIndicator: View {
    var currentIndex: Int
    var pageCount: Int
    
    var body: some View {
        HStack {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(currentIndex == index ? Color.white : Color.gray)
                    .frame(width: 8, height: 8)
            }
        }
    }
}


struct OnboardingFlowView: View {
    @State private var selectedIndex = 0
    @ObservedObject private var stateManager = StateManager.shared

    var body: some View {
        ZStack {
            Color("PhraseGreen")
                .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $selectedIndex) {
                WriteExplain().tag(0)
                VisualizeExplain().tag(1)
                ReflectExplain().tag(2)
                Color.clear.tag(3) // Add a blank view at the end
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide the default page indicator
            .edgesIgnoringSafeArea(.all) // Makes the tab view full screen
            .onChange(of: selectedIndex) { newIndex in
                if newIndex == 3 { // Index of the blank view
                    stateManager.showDailyEntry = true
                }
            }
            
            VStack {
                Spacer()
                CustomPageIndicator(currentIndex: min(selectedIndex, 2), pageCount: 3) // Use custom page indicator
                    .padding(.bottom)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: DailyEntry(),
                isActive: $stateManager.showDailyEntry
            ) {
                EmptyView()
            }
        )
    }
}

struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlowView()
    }
}
