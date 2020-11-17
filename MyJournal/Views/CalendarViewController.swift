//
//  CalendarViewController.swift
//  MyJournal
//
//  Created by Nipun Singh on 11/16/20.
//

import UIKit
import RealmSwift
import JTAppleCalendar

class DateCell: JTACDayCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellRect: UIView!
}

class DateHeader: JTACMonthReusableView  {
    @IBOutlet var monthTitle: UILabel!
}

class CalendarViewController: UIViewController {
    
    let realm = try! Realm()
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
    
    @IBOutlet weak var calendarView: JTACMonthView!
    
    var datesWithEntries: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getEntriesDates()
        
        calendarView.scrollDirection = .vertical
        calendarView.showsVerticalScrollIndicator = false
        calendarView.scrollingMode = .stopAtEachCalendarFrame
//        let components = Calendar.current.dateComponents([.year, .month], from: Date())
//        let startOfMonth = Calendar.current.date(from: components)!
        calendarView.scrollToDate(Date(), animateScroll: false, preferredScrollPosition: .top)
    }
    
    func getEntriesDates() {
        let entries = realm.objects(Entry.self)
        for entry in entries {
            let date = entry.date!
            datesWithEntries.append(date)
        }
        
        calendarView.reloadData()
    }
}

extension CalendarViewController: JTACMonthViewDataSource, JTACMonthViewDelegate {
    
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let formatter2 = DateFormatter()  // Declare this outside, to avoid instancing this heavy class multiple times.
        formatter2.dateFormat = "MMMM yyyy"
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        header.monthTitle.text = formatter2.string(from: range.start)
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return MonthSize(defaultSize: 50)
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! DateCell
        cell.dateLabel.text = cellState.text
        
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        cell.dateLabel.text = cellState.text
        
        //If cell has entry, show dot and highlight
        let cellsDate = formatter.string(from: date)
        if datesWithEntries.contains(cellsDate) {
            cell.cellRect.isHidden = false
            cell.dateLabel.textColor = .label
        } else {
            cell.cellRect.isHidden = true
            cell.dateLabel.textColor = .placeholderText
        }
        
        cell.cellRect.layer.cornerRadius = 5
        return cell
    }
    
    
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let firstEntryDate = formatter.date(from: "Jan 1, 2020")! //TODO: Calculate date of first entry - 1 year
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
        
        return ConfigurationParameters(startDate: firstEntryDate, endDate: endDate, generateInDates: .off,generateOutDates: .off, hasStrictBoundaries: true)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let selectedDate = (formatter.string(from: date))
        print("Selected: \(selectedDate)")
        
        if let selectedEntry = realm.objects(Entry.self).filter("date == %@", selectedDate).first {
            let timestamp = selectedEntry.timestamp ?? Date()
            let mood = selectedEntry.mood ?? "None"
            if let presenter = presentingViewController as? EntryViewController {
                presenter.presentedDate = timestamp
                presenter.presentedMood = mood
                presenter.getEntry()
            }
        } else {
            if let presenter = presentingViewController as? EntryViewController {
                presenter.presentedDate = date
                presenter.getEntry()
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
