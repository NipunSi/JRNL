//
//  SearchViewController.swift
//  MyJournal
//
//  Created by Nipun Singh on 11/14/20.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController {
    
    let realm = try! Realm()
    
    var searchedEntries: Results<Entry>?
    
    var searchFilter = "Content"
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchControl: UISegmentedControl!
    @IBOutlet weak var resultsNumberLabel: UILabel!
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.tableFooterView = UIView()
        
    }
    
    @IBAction func searchFilterChanged(_ sender: UISegmentedControl) {
        searchFilter = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        searchBar.placeholder = "Search by \(searchFilter.lowercased())"
    }
}

//MARK: - Table View Setup
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchedEntries?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchedEntries?[section].date ?? ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        cell.textLabel?.text = "\(searchedEntries?[indexPath.section].content ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Dismiss list view and pass the selected timestamp as the presentedData
        let timestamp = searchedEntries?[indexPath.section].timestamp ?? Date()
        let mood = searchedEntries?[indexPath.section].mood ?? "None"
        
        if let presenter = presentingViewController as? EntryViewController {
            presenter.presentedDate = timestamp
            presenter.presentedMood = mood
            presenter.getEntry()
            //presenter.refresh()
        }
        dismiss(animated: true, completion: nil)
    }
    
    
}

//MARK: - Search Bar Methods
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchedEntries = realm.objects(Entry.self).filter("\(searchFilter.lowercased()) CONTAINS[cd] %@", searchBar.text ?? "").sorted(byKeyPath: "timestamp", ascending: true)
        print("\(searchedEntries?.count ?? 0) Search Results")
        resultsNumberLabel.text = "\(searchedEntries?.count ?? 0) results"
        searchTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            searchedEntries = realm.objects(Entry.self).filter("FALSEPREDICATE")
            resultsNumberLabel.text = ""
            searchTableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
