//
//  StateManager.swift
//  Phrase
//
//  Created by Melanie Zhou on 2/18/24.
//

import Foundation
import Firebase
import FirebaseAuth

class StateManager: ObservableObject {
    static let shared = StateManager()
    static let model = ViewModel()
    
    @Published var userId: String
    private(set) var isUserLoggedIn: Bool = false
    
    @Published var todayEntry: Bool = false
    @Published var toLoadPastEntries: Bool = false
    @Published var toReloadPastEntries: Bool = false
    
    @Published var toAddJournal: Bool = false
    @Published var toInsideJournal: Bool = false
    @Published var toJournalScreen: Bool = false
    
    // NEW ADDITION TO PREVENT RELOADING
    @Published var toLoadJournalScreen: Bool = false
    
    @Published var congratsScreen: Bool = false
    @Published var singleEntry: Bool = false
    @Published var showJournals: Bool = false
    
    @Published var shouldRefreshSingleEntry: Bool = false
    @Published var shouldRefreshInsideJournal: Bool = false
    @Published var shouldRefreshPastEntries: Bool = false
    
    @Published var showDailyEntry: Bool = false
    @Published var showLoginView: Bool = false
    
    @Published var toWriteExplain: Bool = false
    @Published var toVisualizeExplain: Bool = false
    @Published var toReflectExplain: Bool = false
    @Published var toCreateAccount: Bool = false
    
    @Published var toWelcomeView: Bool = false
    
    
    func updateJournalIDs(_ updatedJournalIDs: [String], _ entryID: String) {
        if let index = StateManager.model.entries.firstIndex(where: { $0.entry_id == entryID }) {
            StateManager.model.entries[index].journal_ids = updatedJournalIDs
        }
    }
    
    func submittedToday() {
        todayEntry = true
    }
    
    func loadJournals () {
        showJournals = true
    }
    
    func loadPastEntries () {
        toLoadPastEntries = true
    }
    
    func loadSingleEntry() {
        singleEntry = true
    }
    
    func reloadPastEntries () {
        toReloadPastEntries = true
    }
    
    func submitConfirmation () {
        congratsScreen = true
    }
    
    private init() {
        self.userId = ""
    }
    
    func loginUser(userId: String) {
        isUserLoggedIn = true
        self.userId = userId
    }
    
    func shouldShowDaily() {
        showDailyEntry = true
    }
    
    func shouldLogin() {
        showLoginView = true
    }
    
    func logoutUser() {
        isUserLoggedIn = false
        todayEntry = false
        toLoadPastEntries = false
        toReloadPastEntries = false
        toAddJournal = false
        toInsideJournal = false
        toJournalScreen = false
        toLoadJournalScreen = false
        congratsScreen = false
        singleEntry = false
        showJournals = false
        shouldRefreshSingleEntry = false
        shouldRefreshInsideJournal = false
        shouldRefreshPastEntries = false
        showDailyEntry = false
        showLoginView = false
        toWriteExplain = false
        toVisualizeExplain = false
        toReflectExplain = false
        toCreateAccount = false
        toWelcomeView = false
        userId = ""
    }
    
    
}
