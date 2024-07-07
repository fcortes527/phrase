import SwiftUI

struct JournalEntriesView: View {
    @ObservedObject private var viewModel = StateManager.model
    @State private var month_year = ""
    @State private var monthYearOptions = [""]
    @State private var selectedMonthYearIndex = 0
    @State var journalSelected: String // Change to Binding<String>
    @State private var isEditMode = false // Add edit mode state
    @State private var isRenaming = false // Add renaming state
    @State private var editedJournalName = "" // Add state to hold edited journal name
    @State private var displayJournal = ""
    @State private var navigationBarTitle = "Journal Entries" // Add state to hold navigation bar title
    @ObservedObject private var stateManager = StateManager.shared
    @State private var reloadPage = UUID() // State variable to trigger view reload
    
    init(journalSelected: String) {
        self._journalSelected = State(initialValue: journalSelected)
        self._displayJournal = State(initialValue: mapIDtoLabel(journal_id: journalSelected))
    }
    
    func sortByDate(_ entries: [Entry]) -> [Entry] {
        var copy = entries // entries is immutable
        copy.sort { $0.created_date > $1.created_date }
        return copy
    }
    
    func reloadCache() {
        viewModel.reloadCache();
    }
    
    func filterEntries(entries: [Entry]) -> [Entry] {
        var uniqueEntryIDs: Set<String> = Set() // Set to store unique entry IDs
        var filteredEntries: [Entry] = []
        
        for entry in entries {
            if entry.journal_ids.contains(journalSelected) && !uniqueEntryIDs.contains(entry.entry_id) {
                filteredEntries.append(entry)
                uniqueEntryIDs.insert(entry.entry_id)
            }
        }
        // Print filtered size
        print("Filtered size: \(filteredEntries.count)")
        return filteredEntries
    }
    
    // Define the layout for a 2-column grid
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
    ]
    
    let color = Color("PhraseGreen")
    
    var body: some View {
        let color = Color("PhraseGreen")
        
        VStack { // Embed in NavigationView
            VStack {
                
                NavigationLink(destination: JournalScreen(), isActive: $stateManager.toJournalScreen) {
                    EmptyView()
                }
                
                ZStack {
                    Color("PhraseGreen")
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 20)
                }
                .foregroundColor(.white)
                .accentColor(.white)
                
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(displayJournal)
                            .foregroundColor(.white) // Set your desired color here
                            .font(.headline)
                    }
                    ToolbarItem(placement: .navigation) {
                        Button(action: {
                            stateManager.toInsideJournal = false
                            stateManager.toJournalScreen = true
                        }) {
                            Text("Back")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                }
                .id(reloadPage) // Re-render the view when reloadPage changes
                
                HStack { // Horizontal stack for buttons
                    if !isEditMode {
                        Spacer()
                    }
                    Button(action: {
                        isEditMode.toggle() // Toggle edit mode
                    }) {
                        if isEditMode && !isRenaming {
                            Text("Done")
                                .foregroundColor(color)
                                .padding()
                        } else if !isEditMode && !isRenaming {
                            Text("Edit") // Change button text based on edit mode
                                .foregroundColor(color)
                                .padding()
                        }
                        if isEditMode && !isRenaming { // Show delete and rename options only in edit mode
                            Button(action: {
                                viewModel.deleteJournal(journalId: journalSelected)
                                viewModel.deleteImage(journalId: journalSelected)
                                viewModel.removeJournalIdFromEntries(journalId: journalSelected) // also remove from entries
                                stateManager.toLoadPastEntries = true;
                                
                                stateManager.toInsideJournal = false
                                stateManager.toJournalScreen = true // automatically leave
                            }) {
                                Label("Delete Journal", systemImage: "trash")
                            }
                            Button(action: {
                                isRenaming.toggle() // Toggle renaming mode
                            }) {
                                Label("Rename Journal", systemImage: "pencil")
                            }
                            
                        }
                        
                    }
                }
                
                HStack { // Added VStack to properly align the text field and "Done" button
                    if isRenaming {
                        TextField("New Journal Name", text: $editedJournalName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .foregroundColor(.black)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(color, lineWidth: 1)
                                    .padding(.horizontal)
                                
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical)
                    }
                    if isRenaming{
                        Button(action: {
                            if !editedJournalName.isEmpty {
                                viewModel.writeData(collection: "journal", lookup_field: "journal_id" ,supplied_field: journalSelected , field_to_change: "journal_label", new_value: editedJournalName, callback: reloadCache)
                                
                                displayJournal = editedJournalName
                                reloadPage = UUID()
                            }
                            isRenaming = false // Hide text field
                        }) {
                            Text("Done")
                                .foregroundColor(color)
                                .padding() // Added padding
                        }
                    }
                }
                
                .foregroundColor(.white)
                .accentColor(.white)
                .padding(.trailing, 10)
                
                
                ScrollView {
                    VStack(spacing: 16) {
                        let filtered = filterEntries(entries: viewModel.entries) // Filter the entries
                        let sorted = sortByDate(filtered)
                        ForEach(sorted, id: \.entry_id) { entry in
                            CardViewJournal(entry_text: entry.entry_text,
                                            time: (formatTimeString(entry.created_date) ?? "Unknown Time"),
                                            date: (formatDateString(entry.created_date) ?? "Unknown Date"),
                                            journal_id: journalSelected,
                                            entry_id: entry.entry_id,
                                            isEditMode: isEditMode
                            )
                            .shadow(color: .gray, radius: 5, x: 0, y: 2)
                            .padding()
                        }
                    }
                }
                .onAppear {
                    guard stateManager.toLoadJournalScreen else { return }
                    viewModel.reloadCache()
                    stateManager.toLoadJournalScreen = false // DONT RELOAD AGAIN
                }
                
                .onReceive(stateManager.$shouldRefreshInsideJournal) { shouldRefresh in
                    if shouldRefresh {
                        print("refresh inside journal")
                        viewModel.reloadEntries()
                    }
                }
            }
            .navigationBarBackButtonHidden(true) // Apply this modifier here
        }
    }
}

struct CardViewJournal: View {
    @ObservedObject var viewModel = StateManager.model
    @ObservedObject private var stateManager = StateManager.shared
    let entry_text: String
    let time: String
    let date: String
    let journal_id: String
    let entry_id: String
    let isEditMode: Bool
    
    let color = Color("PhraseGreen")
    let light_red = Color(red: 255.0/255.0, green: 127.0/255.0, blue: 127.0/255.0)
    
    private func setRefresh() {
        print("refreshing")
        stateManager.shouldRefreshInsideJournal = true
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
                            // print("hit trash")
                            
                            viewModel.removeJournalFromEntry(entryId: entry_id, journalIdToRemove: journal_id, callback: setRefresh)
                        }) {
                            Text("Untag")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(light_red)
                                .cornerRadius(4)
                        }
                    }
                }.frame(width: 100, alignment: .leading)
                
                VStack(spacing: 20){
                    Text(entry_text)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .frame(width: 200, alignment: .leading)
                }
            }
        }
        
        .frame(maxWidth: .infinity, minHeight: CGFloat(150), maxHeight:  CGFloat(200)) // Adjust according to your UI design
        .padding(.horizontal, 10)
        .padding(.vertical, 20)
        .background(.white) // Ensure this color is defined
        .cornerRadius(8)
    }
}

