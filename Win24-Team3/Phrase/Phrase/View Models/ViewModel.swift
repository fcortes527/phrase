////
////  ViewModel.swift
////  Phrase
////
////  Created by Melanie Zhou on 1/31/24.
////
import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class User {
    var name = ""
    var user_id = ""
    var password = ""
    var profile_img: Data? = nil
}

class Entry {
    var entry_text = "default"
    var user_id = ""
    var journal_ids: [String] = []
    var entry_id = ""
    var created_date = ""
}

class Journal {
    var user_id = ""
    var journal_id = ""
    var journal_label = ""
    var journal_img: Data? = nil
    var journal_color = ""
    var created_date: Date? = nil
}


class ViewModel: ObservableObject {
    @Published var user = User()
    @Published var entries = [Entry]()
    @Published var journals = [Journal]()
    
    // for debugging
    @Published private var readCount: Int = 0
    
    func generateUniqueIdentifiers(count: Int) -> [String] {
        var uniqueIdentifiers = [String]()
        
        for _ in 0..<count {
            let uuid = UUID().uuidString
            uniqueIdentifiers.append(uuid)
        }
        
        return uniqueIdentifiers
    }
    
    func generateUniqueColor() -> String {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        
        let hexString = String(format: "#%02X%02X%02X", red, green, blue)
        return hexString
    }
    
    func clearModel() {
        self.entries = []
        self.journals = []
    }
    
    
    func reloadUser(callback: (() -> Void)? = nil) {
        readDataStr(collection: "user", lookup_field: "user_id", supplied_field: StateManager.shared.userId, callback: callback)
    }
    
    func reloadJournals(callback: (() -> Void)? = nil) {
        self.journals = []
        readDataStr(collection: "journal", lookup_field: "user_id", supplied_field: StateManager.shared.userId, callback: callback)
    }
    
    func reloadEntries(callback: (() -> Void)? = nil) {
        self.entries = []
        readDataStr(collection: "entry", lookup_field: "user_id", supplied_field: StateManager.shared.userId, callback: callback)
    }
    
    func reloadCache(callback: (() -> Void)? = nil) {
        clearModel()
        readDataStr(collection: "journal", lookup_field: "user_id", supplied_field: StateManager.shared.userId, callback: callback)
        readDataStr(collection: "entry", lookup_field: "user_id", supplied_field: StateManager.shared.userId, callback: callback)
        readDataStr(collection: "user", lookup_field: "user_id", supplied_field: StateManager.shared.userId, callback: callback)
    }
    
    func readDataStr(collection: String, lookup_field: String, supplied_field: String, callback: (() -> Void)? = nil) {
        
        readCount += 1
        print("NUM TIMES READ", readCount)
        print(supplied_field)
        
        let db = Firestore.firestore()
        db.collection(collection).whereField(lookup_field, isEqualTo: supplied_field).getDocuments { (querySnapshot, err) in
            if let err = err {
                // Handle the error
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print(document.documentID)
                    switch collection {
                    case "user":
                        let user = User()
                        user.user_id = document.data()["user_id"] as? String ?? ""
                        user.name = document.data()["name"] as? String ?? ""
                        user.password = document.data()["password"] as? String ?? "" // TODO not secure
                        user.profile_img = document.data()["profile_img"] as? Data ?? nil
                        print("Found user!")
                        //                        print(user.name)
                        self.user = user
                        print("HELLO DEBUGGING")
                        print(self.user.user_id)
                        
                    case "entry":
                        let entry = Entry()
                        entry.entry_text = document.data()["entry_text"] as? String ?? ""
                        //                        entry.created_date = document.data()["created_date"] as? Date ?? nil
                        entry.user_id = document.data()["user_id"] as? String ?? ""
                        entry.journal_ids = document.data()["journal_ids"] as? [String] ?? []
                        entry.entry_id = document.data()["entry_id"] as? String ?? ""
                        if let timestamp = document.get("created_date") as? Timestamp, !timestamp.dateValue().timeIntervalSince1970.isZero {
                            entry.created_date = dateToString(timestamp: timestamp)
                        } else {
                            entry.created_date = "gibberish"
                        }
                        print("Found entry!")
                        print (entry.created_date)
                        self.entries.append(entry)
                        
                    case "journal":
                        
                        let journal = Journal()
                        journal.journal_id = document.data()["journal_id"] as? String ?? ""
                        journal.created_date = document.data()["created_date"] as? Date ?? nil
                        journal.journal_label = document.data()["journal_label"] as? String ?? ""
                        journal.journal_img = document.data()["journal_img"] as? Data ?? nil
                        journal.journal_color = document.data()["journal_color"] as? String ?? ""
                        journal.user_id = document.data()["user_id"] as? String ?? ""
                        print("Found journal!")
                        self.journals.append(journal)
                        
                    default:
                        print("Unknown collection: \(collection)") // Debug print
                    }
                    if let callback = callback {
                        callback()
                    } else {
                        print("No callback provided")
                    }
                }
            }
        }
    }
    
    // write single attribute
    func writeData(collection: String, lookup_field: String, supplied_field: String, field_to_change: String, new_value: String, callback: (() -> Void)? = nil) {
        
        let db = Firestore.firestore()
        db.collection(collection).whereField(lookup_field, isEqualTo: supplied_field).getDocuments {  (QuerySnapshot, err) in
            if let err = err {
                // Handle the error
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    print(document.documentID)
                    let documentRef = db.collection(collection).document(document.documentID)
                    
                    // Perform the update operation
                    documentRef.updateData([field_to_change: new_value]) { error in
                        if let error = error {
                            print("Error updating field: \(error)")
                        } else {
                            print("Field updated successfully!")
                        }
                    }
                }
                callback?()
            }
        }
    }
    
    func writeDataArray(collection: String, lookup_field: String, supplied_field: String, field_to_change: String, new_value: [String]) {
        let db = Firestore.firestore()
        db.collection(collection).whereField(lookup_field, isEqualTo: supplied_field).getDocuments {  (QuerySnapshot, err) in
            if let err = err {
                // Handle the error
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    print(document.documentID)
                    let documentRef = db.collection(collection).document(document.documentID)
                    
                    // Perform the update operation
                    documentRef.updateData([field_to_change: new_value]) { error in
                        if let error = error {
                            print("Error updating field: \(error)")
                        } else {
                            print("Field updated successfully!")
                        }
                    }
                }
            }
        }
    }
    
    func createUser(name: String, user_id: String, profile_img: String, password: String) {
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "name": name,
            "user_id": user_id,
            "profile_img": profile_img,
            "password": password
        ]
        
        db.collection("user").addDocument(data: data) { error in
            if let error = error {
                // Handle the error
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully!")
            }
        }
    }
    
    func createEntry(entry_text: String, user_id: String) {
        let db = Firestore.firestore()
        
        let unique_identifiers = generateUniqueIdentifiers(count: 1)
        
        let current_date = Date()
        
        let data: [String: Any] = [
            "created_date": current_date,
            "entry_id": unique_identifiers[0],
            "entry_text": entry_text,
            "journal_ids": [],
            "user_id": user_id,
        ]
        
        db.collection("entry").addDocument(data: data) { error in
            if let error = error {
                // Handle the error
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully!")
            }
        }
    }
    
    func deleteEntry(entryId: String, callback: (() -> Void)? = nil) {
        let db = Firestore.firestore()
        
        db.collection("entry").whereField("entry_id", isEqualTo: entryId).getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found with entryId: \(entryId)")
                return
            }
            
            for document in documents {
                document.reference.delete { error in
                    if let error = error {
                        // Handle the error
                        print("Error deleting entry: \(error)")
                    } else {
                        print("Entry deleted successfully!")
                        self.entries.removeAll { $0.entry_id == entryId }
                        
                        callback?()
                    }
                }
            }
        }
    }
    func removeJournalFromEntry(entryId: String, journalIdToRemove: String, callback: (() -> Void)? = nil) {
        let db = Firestore.firestore()
        
        db.collection("entry").whereField("entry_id", isEqualTo: entryId).getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found with entryId: \(entryId)")
                return
            }
            
            for document in documents {
                let entryRef = db.collection("entry").document(document.documentID)
                entryRef.updateData(["journal_ids": FieldValue.arrayRemove([journalIdToRemove])]) { error in
                    if let error = error {
                        print("Error removing journal from entry: \(error)")
                    } else {
                        print("Journal removed from entry successfully!")
                        if let index = self.entries.firstIndex(where: { $0.entry_id == entryId }) {
                            self.entries[index].journal_ids.removeAll { $0 == journalIdToRemove }
                        }
                        callback?()
                    }
                }
            }
        }
    }
    
    func deleteJournal(journalId: String) {
        let db = Firestore.firestore()
        
        db.collection("journal").whereField("journal_id", isEqualTo: journalId).getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found with journalId: \(journalId)")
                return
            }
            
            for document in documents {
                document.reference.delete { error in
                    if let error = error {
                        // Handle the error
                        print("Error deleting journal: \(error)")
                    } else {
                        print("Journal deleted successfully!")
                        self.journals.removeAll { $0.journal_id == journalId }
                    }
                }
            }
        }
    }
    
    func deleteImage(journalId: String) {
        let db = Firestore.firestore()
        
        db.collection("images").whereField("journal_id", isEqualTo: journalId).getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found with journalId: \(journalId)")
                return
            }
            
            for document in documents {
                document.reference.delete { error in
                    if let error = error {
                        // Handle the error
                        print("Error deleting journal: \(error)")
                    } else {
                        print("Image deleted successfully!")
                        self.journals.removeAll { $0.journal_id == journalId }
                    }
                }
            }
        }
    }
    
    func deleteImageUser(userId: String, callback: (() -> Void)? = nil) {
        let db = Firestore.firestore()
        
        db.collection("images").whereField("user_id", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found with userId: \(userId)")
                return
            }
            
            for document in documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting user image: \(error)")
                    } else {
                        print("Image deleted successfully!")
                    }
                }
            }
            callback?()
        }
    }
    
    // Remove the specified journal_id from the array of IDs in all entries
    func removeJournalIdFromEntries(journalId: String) {
        
        let db = Firestore.firestore()
        db.collection("entry").whereField("journal_ids", arrayContains: journalId).getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found with journalId: \(journalId)")
                return
            }
            
            for document in documents {
                var entryData = document.data()
                if var journalIds = entryData["journal_ids"] as? [String], let index = journalIds.firstIndex(of: journalId) {
                    journalIds.remove(at: index)
                    entryData["journal_ids"] = journalIds
                    
                    document.reference.updateData(entryData) { error in
                        if let error = error {
                            // Handle the error
                            print("Error updating entry: \(error)")
                        } else {
                            print("Journal ID removed from entry successfully!")
                        }
                    }
                }
            }
        }
    }
    
    
    func loadImageFromData(data: Data) -> UIImage? {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        return uiImage
    }
    
    func updateProfilePic(collection: String, lookup_field: String, supplied_field: String, field_to_change: String, new_value: Data?, callback: (() -> Void)? = nil) {
        
        let db = Firestore.firestore()
        db.collection(collection).whereField(lookup_field, isEqualTo: supplied_field).getDocuments {  (QuerySnapshot, err) in
            if let err = err {
                // Handle the error
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    print(document.documentID)
                    let documentRef = db.collection(collection).document(document.documentID)
                    
                    // Perform the update operation
                    documentRef.updateData([field_to_change: new_value]) { error in
                        if let error = error {
                            print("Error updating field: \(error)")
                        } else {
                            print("Field updated successfully!")
                            callback?()
                        }
                    }
                }
            }
        }
        
    }
    
    
    func createJournal(journal_img: Data?, journal_label: String, user_id: String, journal_id: String? = nil) {
        let db = Firestore.firestore()
        
        let current_date = Date()
        let journal_color = generateUniqueColor()
        
        var data: [String: Any] = [
            "created_date": current_date,
            "journal_img": journal_img,
            "journal_label": journal_label,
            "journal_color" : journal_color,
            "user_id": user_id,
        ]
        
        if let journal_id = journal_id {
            data["journal_id"] = journal_id
        } else {
            let unique_identifiers = generateUniqueIdentifiers(count: 1)
            data["journal_id"] = unique_identifiers[0]
        }
        
        db.collection("journal").addDocument(data: data) { error in
            if let error = error {
                // Handle the error
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully!")
            }
        }
    }
    
    func deleteUserAndAllStorage(user_id: String, callback: (() -> Void)? = nil) {
        print("Deleting the user and all storage associated with user_id:", user_id)

        let db = Firestore.firestore()

        db.collection("entry").whereField("user_id", isEqualTo: user_id).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting entries: \(err)")
                return
            }

            for document in querySnapshot!.documents {
                document.reference.delete { err in
                    if let err = err {
                        print("Error deleting entry: \(err)")
                    } else {
                        print("Entry deleted successfully")
                    }
                }
            }

            db.collection("journal").whereField("user_id", isEqualTo: user_id).getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting journals: \(err)")
                    return
                }

                for document in querySnapshot!.documents {
                    document.reference.delete { err in
                        if let err = err {
                            print("Error deleting journal: \(err)")
                        } else {
                            print("Journal deleted successfully")
                        }
                    }
                }

                db.collection("images").whereField("user_id", isEqualTo: user_id).getDocuments { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting images: \(err)")
                        return
                    }

                    for document in querySnapshot!.documents {
                        document.reference.delete { err in
                            if let err = err {
                                print("Error deleting image: \(err)")
                            } else {
                                print("Image deleted successfully")
                            }
                        }
                    }

                    db.collection("user").document(user_id).delete { err in
                        if let err = err {
                            print("Error deleting user document: \(err)")
                            return
                        }

                        print("User document deleted successfully")

                        Auth.auth().currentUser?.delete { err in
                            if let err = err {
                                print("Error deleting user account: \(err)")
                                return
                            }

                            print("User account deleted successfully")

                            print("Logging out")
                            StateManager.shared.logoutUser()

                            callback?()
                        }
                    }
                }
            }
        }
    }
}
