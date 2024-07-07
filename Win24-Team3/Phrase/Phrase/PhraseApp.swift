//
//  PhraseApp.swift
//  Phrase
//
//  Created by Giancarlo Ricci on 1/26/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore


class AppDelegate: NSObject, UIApplicationDelegate {
    private func application(_ application: UIApplication,
                             didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) async -> Bool  {
        FirebaseApp.configure()
        return true
    }
}

@main
struct PhraseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        @ObservedObject var stateManager = StateManager.shared
        WindowGroup {
            
            NavigationView {
                WelcomeView()
                // ContentView()
                //       SubmitConfirm()
                
                //                DailyEntry()
                //         JournalScreen()
                //       PastEntries()
                //          OnboardingFlowView()
                //            CreateAccount()
                // AddJournalView()
                //                          LoginPage()
                //          NavBar()
            }
        }
    }
}
