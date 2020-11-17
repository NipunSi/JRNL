//
//  EntryBrain.swift
//  MyJournal
//
//  Created by Nipun Singh on 11/14/20.
//

import Foundation
import RealmSwift

struct EntryBrain {
    
    let realm = try! Realm()
    let prompts = ["How are you?", "How was your day?", "Whats new?", "How do you feel?"]
    
    var todaysEntryExists = false
    var todaysEntry = Entry()
    
    func getRandomPrompt() -> String {
        return prompts.randomElement()!
    }
    
    func getDateString(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    mutating func loadEntry(from date: Date) -> Entry? {
        let dateString = getDateString(date)
        
        if let entry = realm.objects(Entry.self).filter("date == %@", dateString).first {
            todaysEntryExists = true
            todaysEntry = entry
            return entry
        } else {
            todaysEntryExists = false
            return nil
        }
    }
    
    func saveEntry(content: String, mood: String,/* pictures: UIImage?, */prompt: String, date: Date) {
        //If there is already an entry for this date, update it. Otherwise write this new one.
        do {
            try realm.write {
                if todaysEntryExists {
                    todaysEntry.content = content
                    todaysEntry.mood = mood
                    todaysEntry.prompt = prompt
                    print("Updated existing entry!")
                } else {
                    if content != "" {
                        let newEntry = Entry()
                        newEntry.content = content
                        newEntry.timestamp = date
                        newEntry.mood = mood
                        //newEntry.pictures = pictures
                        newEntry.prompt = prompt
                        
                        
                        newEntry.date = getDateString(date)
                        
                        realm.add(newEntry)
                        print("Saved new entry!")
                    }
                }
            }
        } catch {
            print("Error saving new entry: \(error)")
        }
    }
}
