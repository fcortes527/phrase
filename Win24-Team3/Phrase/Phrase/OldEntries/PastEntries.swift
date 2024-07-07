//
//  PastEntries.swift
//  Phrase
//
//  Created by Melanie Zhou on 2/12/24.
//

import SwiftUI

struct PastEntries: View {
    @State private var month_year = ""
    @State private var monthYearOptions = [""]
    @State private var selectedMonthYearIndex = 0
    @ObservedObject private var stateManager = StateManager.shared
    @ObservedObject private var model = StateManager.model
    @State private var selectedEntry: Entry? = nil
    @State private var isEditMode = false
    
    func filterEntries(_ entries: [Entry]) -> [Entry] {
        var uniqueEntries: Set<String> = Set() // Set to store unique entry IDs
        var filteredEntries: [Entry] = []
        
        for entry in entries {
            let monthYear = extractMonthYear(entry.created_date)
            // Check if the entry's monthYear matches the selected month_year and it's not already added
            if monthYear == month_year && !uniqueEntries.contains(entry.entry_id) {
                filteredEntries.append(entry)
                uniqueEntries.insert(entry.entry_id) // Add entry ID to the set to prevent duplicates
            }
        }
        
        return filteredEntries
    }
    
    func sortByDate(_ entries: [Entry]) -> [Entry] {
        var copy = entries // entries is immutable
        copy.sort { $0.created_date > $1.created_date }
        return copy
    }
    
    // Define the layout for a 2-column grid
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
    ]
    
    var body: some View {
        VStack {
            ZStack {
                Color("PhraseGreen") // Ensure this color is defined in your asset catalog
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 60)
                
                Picker(selection: $selectedMonthYearIndex, label: Text("")) {
                    ForEach(0..<monthYearOptions.count, id: \.self) { index in
                        Text(formatMonthYear(monthYearOptions[index])).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.white)
                .accentColor(.white)
                .onChange(of: selectedMonthYearIndex) { _ in
                    month_year = monthYearOptions[selectedMonthYearIndex]
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        isEditMode.toggle()
                    }) {
                        Text(isEditMode ? "Done" : "Edit")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .padding(.trailing, 20)
                }
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    let filtered = filterEntries(model.entries)
                    let sorted = sortByDate(filtered)
                    
                    ForEach(sorted, id: \.entry_id) { entry in
                        CardViewEntry(entry_text: entry.entry_text,
                                      time: (formatTimeString(entry.created_date) ?? "Unknown Time"),
                                      date: (formatDateString(entry.created_date) ?? "Unknown Date"),
                                      journal_ids: entry.journal_ids,
                                      entry_id: entry.entry_id,
                                      isEditMode: isEditMode
                        )
                        .shadow(color: .gray, radius: 5, x: 0, y: 2)
                        .onTapGesture {
                            print("clicked in past")
                            selectedEntry = entry
                            stateManager.loadSingleEntry()
                            stateManager.toReloadPastEntries = false
                        }
                        .padding()
                    }
                }
            }
            
            .onAppear{
                guard stateManager.toLoadPastEntries else
                {
                    initPicker()
                    return
                }
                loadDataOnce()
                stateManager.toLoadPastEntries = false // DONT RELOAD AGAIN
            }
            .gesture(swipeGesture())
            
            NavigationLink(
                destination: SingleEntry(entry_text: selectedEntry?.entry_text ?? "",
                                         date: (formatDateString(selectedEntry?.created_date ?? "") ?? "Unknown Date"),
                                         time: (formatTimeString(selectedEntry?.created_date ?? "") ?? "Unknown Time"),
                                         journal_ids: selectedEntry?.journal_ids ?? [],
                                         entryID: selectedEntry?.entry_id ?? ""),
                isActive: $stateManager.singleEntry)
            {
                EmptyView()
            }
            
            NavigationLink(
                destination: WelcomeView(), isActive: $stateManager.toWelcomeView)
            {
                EmptyView()
            }
            
            
            NavBar()
        }
        .onDisappear {
            // Reset the navigation state when navigating back
            stateManager.toReloadPastEntries = false
        }
        
        .onReceive(stateManager.$shouldRefreshPastEntries) { shouldRefresh in
            if shouldRefresh {
                model.reloadEntries(callback: initPicker);
                stateManager.shouldRefreshSingleEntry = false
            }
        }
        
        .navigationBarBackButtonHidden(true) // Apply this modifier here
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures correct style on all devices
        .background(.white)
        
    }
    
    private func initPicker() {
        month_year = getCurrentMonthYear()
        selectedMonthYearIndex = monthYearOptions.firstIndex(of: month_year) ?? 0
        monthYearOptions = generateMonthYearOptions(model.entries)
    }
    
    func loadDataOnce() {
        model.reloadCache(callback: initPicker)
    }
    
    private func swipeGesture() -> some Gesture {
        return DragGesture(minimumDistance: 50, coordinateSpace: .local)
            .onEnded { value in
                if value.translation.width > 0 {
                    print("Swiped right")
                    month_year = tryIncrementMonth(month_year, model.entries)
                    if let newIndex = monthYearOptions.firstIndex(of: month_year) {
                        selectedMonthYearIndex = newIndex
                    }
                } else if value.translation.width < 0 {
                    print("Swiped left")
                    month_year = tryDecrementMonth(month_year, model.entries)
                    if let newIndex = monthYearOptions.firstIndex(of: month_year) {
                        selectedMonthYearIndex = newIndex
                    }
                }
            }
    }
}

struct CardViewEntry: View {
    let entry_text: String
    let time: String
    let date: String
    let journal_ids: [String]
    let entry_id: String
    let isEditMode: Bool
    @ObservedObject private var model = StateManager.model
    @ObservedObject private var stateManager = StateManager.shared
    
    
    let color = Color("PhraseGreen")
    
    private func setRefresh() {
        print("refreshing")
        stateManager.shouldRefreshPastEntries = true
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 20){
                VStack(spacing: 10){
                    Text(date)
                        .font(.title)
                        .foregroundColor(color)
                    Text(time)
                        .font(.caption2)
                        .foregroundColor(color)
                    if isEditMode {
                        Button(action: {
                            print("clicked on trash")
                            model.deleteEntry(entryId: entry_id, callback: setRefresh)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(color)
                        }
                    }
                }.frame(width: 100, alignment: .leading)
                
                VStack(spacing: 20){
                    Text(entry_text)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .frame(width: 200, alignment: .leading)
                    HStack {
                        if !journal_ids.isEmpty {
                            ForEach(0..<min(journal_ids.count, 3), id: \.self) { index in
                                if (journal_ids[index] != "") { // TODO: replace with id so this shouldn't matter
                                    let journal_label = mapIDtoLabel(journal_id: journal_ids[index])
                                    let journal_color = mapIDtoColor(journal_id: journal_ids[index])
                                    LabelView(label: journal_label, colorHex: journal_color )
                                        .padding(.horizontal, 10)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: CGFloat(150), maxHeight:  CGFloat(200))
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
        .background(.white) // Ensure this color is defined
        .cornerRadius(8)
    }
}
