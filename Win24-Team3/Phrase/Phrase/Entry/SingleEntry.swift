//
//  SingleEntry.swift
//  Phrase
//
//  Created by Melanie Zhou on 2/26/24.
//

//import Foundation
//import SwiftUI
//
//
import SwiftUI

struct SingleEntry: View {
    let LABEL_LIMIT = 3 // limit users to 3 labels
    @State private var selectedLabelIndex = 0
    @State private var customLabel = ""
    @ObservedObject private var stateManager = StateManager.shared
    let entry_text: String
    let date: String
    let time: String
    @State var journal_ids: [String]
    let entryID: String
    @ObservedObject private var model = StateManager.model
    
    
    let color = Color("PhraseGreen")
    var body: some View {
        VStack {
            Spacer() // Pushes content to the bottom
            ZStack {
                Color("PhraseGreen")
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        stateManager.reloadPastEntries()
                        stateManager.singleEntry = false // ensure we clear
                    }
                
                HStack{
                    Spacer()
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color.white)
                        .shadow(radius: 10)
                        .frame(height: UIScreen.main.bounds.height * 2 / 3)
                    Spacer()
                }
                
                
                VStack(alignment: .leading, spacing: 50) {
                    HStack{
                        Spacer()
                        let pastLabels = getUniqueJournalLabels()
                        Picker(selection: $selectedLabelIndex, label: Text("Select a Journal")) {
                            ForEach(0..<pastLabels.count, id: \.self) {
                                Text(pastLabels[$0].1)
                            }
                            
                            .pickerStyle(MenuPickerStyle())
                            
                        }
                        
                        Button(action: {
                            // Handle the selection based on the chosen Label
                            let selected_id = selectedLabelIndex == pastLabels.count ? customLabel : pastLabels[selectedLabelIndex].0
                            print("Selected Label: \(selected_id)")
                            
                            
                            if journal_ids.count < LABEL_LIMIT {
                                let new_id = selected_id
                                if !journal_ids.contains(new_id) {
                                    journal_ids.append(new_id)
                                }
                                
                                StateManager.model.writeDataArray(collection: "entry", lookup_field: "entry_id", supplied_field: entryID, field_to_change: "journal_ids", new_value: journal_ids)
                                
                                stateManager.updateJournalIDs(journal_ids, entryID)
                                
                            } else {
                                // TODO: display to user can't add more
                            }
                        }) {
                            if pastLabels.count > 0 {
                                Text("Select Journal")
                                    .frame(width: 100, height: 40)
                                    .font(.caption2)
                                    .background(color)
                                    .foregroundColor(.white)
                                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    VStack{
                        HStack{
                            Spacer()
                            Text(date)
                                .font(.subheadline)
                                .foregroundColor(color)
                            Text (time)
                                .font(.subheadline)
                                .foregroundColor(color)
                            Spacer()
                        }
                        HStack{
                            Spacer()
                            Text(entry_text)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Spacer()
                        }
                    }
                    
                    HStack {
                        Spacer()
                        //                            var pastLabels = getUniqueJournalLabels(entries: StateManager.model.entries, entryID: entry_id)
                        if !journal_ids.isEmpty {
                            ForEach(0..<min(journal_ids.count, 3), id: \.self) { index in
                                if (journal_ids[index] != "") { // TODO: replace with id so this shouldn't matter
                                    let journal_label = mapIDtoLabel(journal_id: journal_ids[index])
                                    let journal_color = mapIDtoColor(journal_id: journal_ids[index])
                                    LabelViewSingleEntry(label: journal_label, colorHex: journal_color, journal_id: journal_ids[index], entry_id: entryID)
                                        .padding(.bottom, 5)
                                        .padding(.horizontal, 10)
                                    
                                }
                            }
                        }
                        Spacer()
                        
                    }
                    .padding()
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            //                            print("clicked delete entry!")
                            model.deleteEntry(entryId: entryID)
                            stateManager.loadPastEntries()
                            stateManager.reloadPastEntries()
                            stateManager.singleEntry = false // ensure we clear
                        }) {
                            Label("Delete Entry", systemImage: "trash")
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            
            
            NavigationLink(destination: PastEntries(), isActive: $stateManager.toReloadPastEntries) {
                EmptyView()
            }
            
        }
        .onReceive(stateManager.$shouldRefreshSingleEntry) { shouldRefresh in
            if shouldRefresh {
                model.reloadEntries(callback: updateJournalIds);
                stateManager.shouldRefreshSingleEntry = false
            }
        }
        .background(color)
        .navigationBarBackButtonHidden(true) // Apply this modifier here
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures correct style on all devices
    }
    
    func updateJournalIds() {
        if let entry = model.entries.first(where: { $0.entry_id == entryID }) {
            journal_ids = entry.journal_ids
        }
        print("done updating ids")
    }
    
    func getUniqueJournalLabels() -> [(String, String)] {
        var journal_info: [(String, String)] = []
        for journal in StateManager.model.journals {
            if !journal_info.contains(where: { $0.0 == journal.journal_id }) {
                journal_info.append((journal.journal_id, journal.journal_label))
            }
        }
        return journal_info
    }
}

func mapIDtoLabel(journal_id: String) -> String {
    var journalLabel = ""
    for journal in StateManager.model.journals {
        if journal_id == journal.journal_id {
            journalLabel = journal.journal_label
            return journalLabel
        }
    }
    return ""
}

func mapIDtoColor(journal_id: String) -> String {
    var journal_color = ""
    for journal in StateManager.model.journals {
        if journal_id == journal.journal_id {
            journal_color = journal.journal_color
            return journal_color
        }
    }
    return ""
}

