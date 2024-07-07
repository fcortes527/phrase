import SwiftUI

struct JournalScreen: View {
    @ObservedObject private var viewModel = StateManager.model
    @ObservedObject private var stateManager = StateManager.shared
    @State private var selectedJournal: String?
    
    var body: some View {
        let color = Color("PhraseGreen")
        
        let columns: [GridItem] = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
        ]
        
        VStack {
            
            ZStack {
                Color("PhraseGreen") // Ensure this color is defined in your asset catalog
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 60)
                
                HStack {
                    Text("My Journals")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Spacer()
                    Button(action: {
                        stateManager.toAddJournal = true;
                        stateManager.toJournalScreen = false;
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    
                }
                .padding(.leading, 20)
                .padding(.trailing, 10)
                
            }
            
            ZStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.journals, id: \.journal_id) { journal in
                            JournalItemView(journal: journal)
                                .onTapGesture {
                                    selectedJournal = journal.journal_id
                                    stateManager.toInsideJournal = true
                                    stateManager.toJournalScreen = false
                                }
                        }
                    }
                    
                }
            }
            
            NavigationLink(destination: JournalEntriesView(journalSelected: selectedJournal ?? ""), isActive: $stateManager.toInsideJournal) { EmptyView() }
            
            NavigationLink(destination: AddJournalView(), isActive: $stateManager.toAddJournal) {
                EmptyView()
            }
            
            Spacer()
            NavBar()
                .navigationBarHidden(true)
                .onAppear {
                    guard stateManager.toLoadJournalScreen else { return }
                    loadDataOnce()
                    stateManager.toLoadJournalScreen = false // DONT RELOAD AGAIN
                }
        }
    }
    func loadDataOnce() {
        print("loading once in journal!")
        viewModel.reloadCache()
    }
}

struct JournalItemView: View {
    let journal: Journal
    var default_color: Color {
        Color.fromHex(journal.journal_color)
    }
    var body: some View {
        VStack {
            if let imageData = journal.journal_img, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill).clipped()
                    .frame(minWidth:CGFloat(150), maxWidth: CGFloat(150),  minHeight: CGFloat(250), maxHeight:  CGFloat(250))
                    .cornerRadius(10)
                
            } else {
                Rectangle()
                    .fill(default_color)
                    .aspectRatio(contentMode: .fill).clipped()
                    .frame(minWidth:CGFloat(150), maxWidth: CGFloat(150), minHeight: CGFloat(250), maxHeight:  CGFloat(250))
                    .cornerRadius(10)
            }
            
            Text(journal.journal_label)
                .foregroundColor(default_color)
                .font(.headline)
                .padding()
                .cornerRadius(10)
            
        }
        .padding(.horizontal, 10)
    }
}
