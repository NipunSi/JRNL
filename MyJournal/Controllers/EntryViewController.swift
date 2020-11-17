//
//  ViewController.swift
//  MyJournal
//
//  Created by Nipun Singh on 11/13/20.
//

import UIKit
import RealmSwift

class EntryViewController: UIViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var entryTextView: UITextView!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var moodButton: UIButton!
    
    var entryBrain = EntryBrain()
    
    var presentedDate = Date()
    var presentedMood = "None"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        entryTextView.delegate = self
        
        dateLabel.text = entryBrain.getDateString(presentedDate)
        promptLabel.text = entryBrain.getRandomPrompt()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        setUpKeyboardBar()
        setUpBottomBar()
        setUpMoodButton()
        getEntry()
    }
    
    func getEntry() {
        dateLabel.text = entryBrain.getDateString(presentedDate)
        if let entry = entryBrain.loadEntry(from: presentedDate) {
            entryTextView.text = entry.content
            promptLabel.text = entry.prompt
            moodButton.setImage(UIImage(named: "\(entry.mood?.lowercased() ?? "none")50")?.withTintColor(.label), for: .normal)
            if entry.mood == "None" {
                moodButton.alpha = 0.6
            } else {
                moodButton.alpha = 1.0
            }
        } else {
            entryTextView.text = ""
            promptLabel.text = entryBrain.getRandomPrompt()
            moodButton.setImage(UIImage(named: "neutral50")?.withTintColor(.label).withTintColor(.label), for: .normal)
            moodButton.alpha = 0.6
        }
    }
    
    @IBAction func refreshPromptPressed(_ sender: Any) {
        promptLabel.text = entryBrain.getRandomPrompt()
        entryBrain.saveEntry(content: entryTextView.text, mood: presentedMood, prompt: promptLabel.text!, date: presentedDate)
    }
    
    
    @objc func doneTapped() {
        print("Done editing")
        //entryTextView.resignFirstResponder()
        entryTextView.endEditing(true)
        
        entryBrain.saveEntry(content: entryTextView.text, mood: presentedMood, prompt: promptLabel.text!, date: presentedDate)
    }
    
    @objc func goToList() {
        performSegue(withIdentifier: "goToList", sender: self)
    }
    
    @objc func goToSearch() {
        performSegue(withIdentifier: "goToSearch", sender: self)
    }
    
    @objc func goToCalendar() {
        performSegue(withIdentifier: "goToCalendar", sender: self)
    }
    
    @objc func goToSettings() {
        performSegue(withIdentifier: "goToSettings", sender: self)
    }
    
    @objc func goBackADay() {
        let newDate = Calendar.current.date(byAdding: .day, value: -1, to: presentedDate)
        presentedDate = newDate!
        getEntry()
        //refresh()
    }
    
    @objc func goForwardsADay() {
        let newDate = Calendar.current.date(byAdding: .day, value: 1, to: presentedDate)
        presentedDate = newDate!
        getEntry()
        //refresh()
    }
    
    func setMood(_ mood: String) {
        print("Mood set to: \(mood)")
        presentedMood = mood
        moodButton.setImage(UIImage(named: "\(mood.lowercased())50")?.withTintColor(.label), for: .normal)
        entryBrain.saveEntry(content: entryTextView.text, mood: presentedMood, prompt: promptLabel.text!, date: presentedDate)
    }
    
    //MARK: - Set up UI
    func setUpMoodButton() {
        let sadFace = UIImage(named: "sad50")?.withTintColor(.label)
        let neutralFace = UIImage(named: "neutral50")?.withTintColor(.label)
        let happyFace = UIImage(named: "happy50")?.withTintColor(.label)
        
        let menu = UIMenu(title: "Today's Mood", children: [
            UIAction(title: "Sad", image: sadFace,
                     handler: {_ in self.setMood("Sad")}),
            UIAction(title: "Neutral", image: neutralFace,
                     handler: {_ in self.setMood("Neutral")}),
            UIAction(title: "Happy", image: happyFace,
                     handler: {_ in self.setMood("Happy")})
        ])
        if presentedMood != "None" {
            moodButton.setImage(UIImage(named: "\(presentedMood.lowercased())50")?.withTintColor(.label), for: .normal)
        } else {
            moodButton.setImage(neutralFace, for: .normal)
        }
        moodButton.menu = menu
        moodButton.showsMenuAsPrimaryAction = true
    }
    
    func setUpKeyboardBar() {
        let bar = UIToolbar()
        let reset = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        let picture = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        bar.items = [picture, flexibleSpace, reset]
        bar.sizeToFit()
        bar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        //bar.barStyle = .black
        //bar.clipsToBounds = true
        
        bar.tintColor = .label //Or .white if in darkmode
        
        entryTextView.inputAccessoryView = bar
    }
    
    func setUpBottomBar() {
        //Bottom toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let calendar = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(goToCalendar))
        let leftArrow = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(goBackADay))
        let rightArrow = UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: self, action: #selector(goForwardsADay))
        let search = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(goToSearch))
        let settings = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(goToSettings))
        let list = UIBarButtonItem(image: UIImage(systemName: "list.dash"), style: .plain, target: self, action: #selector(goToList))
        
        bottomBar.setItems([calendar, flexibleSpace, list, flexibleSpace, leftArrow, rightArrow, flexibleSpace, search, flexibleSpace, settings], animated: true)
        bottomBar.sizeToFit()
        bottomBar.tintColor = .label
        bottomBar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        //bottomBar.barStyle = .black
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            entryTextView.contentInset = .zero
        } else {
            entryTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        entryTextView.scrollIndicatorInsets = entryTextView.contentInset
        
        let selectedRange = entryTextView.selectedRange
        entryTextView.scrollRangeToVisible(selectedRange)
    }
}

extension EntryViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        //print("Saving entry")
    }
}
