//
//  SettingsViewController.swift
//  MyJournal
//
//  Created by Nipun Singh on 11/16/20.
//

import UIKit
import RealmSwift

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Reminders"
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.textLabel?.text = "Passcord"
            cell.accessoryType = .disclosureIndicator
        case 2:
            cell.textLabel?.text = "Appearance"
            cell.accessoryType = .disclosureIndicator
        case 3:
            cell.textLabel?.text = "Export"
            cell.accessoryType = .disclosureIndicator
        case 4:
            cell.textLabel?.text = "Storage"
            cell.accessoryType = .disclosureIndicator
        case 5:
            cell.textLabel?.text = "Leave A Review"
        case 6:
            cell.textLabel?.text = "Contact"
        case 7:
            cell.textLabel?.text = "Made by Nipun Singh"
        default:
            cell.textLabel?.text = ""
        }

        return cell
    }
}
