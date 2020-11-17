//
//  ListViewController.swift
//  MyJournal
//
//  Created by Nipun Singh on 11/14/20.
//

import UIKit
import RealmSwift

class ListViewController: UITableViewController {
    
    @IBOutlet weak var entriesLabel: UILabel!
    
    let realm = try! Realm()
    
    var entries: Results<Entry>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Load all entries, sorted by date
        //Add a search bar
        loadEntries()
        tableView.tableFooterView = UIView()

    }

    func loadEntries() {
        entries = realm.objects(Entry.self).sorted(byKeyPath: "timestamp", ascending: false)
        if entries?.count == 0 {
            entriesLabel.text = "No Entries"
        } else {
            if entries?.count == 1 {
                entriesLabel.text = "1 Entry"
            } else {
                entriesLabel.text = "\(entries?.count ?? 0) Entries"
            }
        }
        print("Got Entries!")
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return entries?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let entryNumber = (entries?.count ?? 0) - (section)
        return "\(entryNumber) - \(entries?[section].date ?? "")"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        cell.textLabel?.text = "\(entries?[indexPath.section].content ?? "")"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Dismiss list view and pass the selected timestamp as the presentedData
        let timestamp = entries?[indexPath.section].timestamp ?? Date()
        let mood = entries?[indexPath.section].mood ?? "None"
        if let presenter = presentingViewController as? EntryViewController {
            presenter.presentedDate = timestamp
            presenter.presentedMood = mood
            //presenter.refresh()
            presenter.getEntry()
        }
        dismiss(animated: true, completion: nil)
    }
}
