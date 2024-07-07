//
//  FEComponents.swift
//  Phrase
//
//  Created by Melanie Zhou on 2/22/24.
//

import Foundation
import SwiftUI


//extension UIColor {
//    // Helper function to get RGBA components of a UIColor
//    var rgbaComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//
//        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//
//        return (red, green, blue, alpha)
//    }
//}


extension Color {
    // Function to create a Color from a hex string
    static func fromHex(_ hex: String, opacity: Double = 1.0) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

struct LabelViewSingleEntry: View {
    let label: String
    let colorHex: String
    let journal_id: String
    let entry_id: String
    @ObservedObject private var stateManager = StateManager.shared
    @ObservedObject private var model = StateManager.model
    
    private func setRefresh() {
//        print("refreshing")
        stateManager.shouldRefreshSingleEntry = true
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .background(Color.fromHex(colorHex))
                .cornerRadius(4)
            
            Button(action: {
                //print("clicked on delete journal")
                model.removeJournalFromEntry(entryId: entry_id, journalIdToRemove: journal_id, callback: setRefresh)
                
            }) {
                Image(systemName: "xmark.circle.fill") // Corrected system symbol
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
            }
        }
    }
}

// Special textfield to support colored placeholder text
struct SuperTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                .autocapitalization(.none)      // keep auto-cap off for password fields
        }
    }
}
// Same as above, support colored placeholder text in securefield
struct SuperSecureField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool)->() = { _ in }
    var commit: ()->() = { }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            SecureField("", text: $text, onCommit: commit)
                .autocapitalization(.none)      // keep auto-cap off for password fields
        }
    }
}

// TODO: redesign label
struct LabelView: View {
    let label: String
    let colorHex: String
    
    var body: some View {
        Text(label)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .background(Color.fromHex(colorHex))
            .cornerRadius(4)
    }
}

