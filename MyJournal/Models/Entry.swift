//
//  Entry.swift
//  MyJournal
//
//  Created by Nipun Singh on 11/13/20.
//

import Foundation
import RealmSwift
 
class Entry: Object {
    @objc dynamic var timestamp: Date?
    @objc dynamic var content: String?
    @objc dynamic var prompt: String? //Maybe prompts: [String]
    @objc dynamic var pictures: String?
    @objc dynamic var mood: String?
    @objc dynamic var date: String?
}
