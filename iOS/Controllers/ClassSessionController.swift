//
// Created by Hank Brekke on 10/1/17.
// Copyright (c) 2017 Hank Brekke. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class ClassSessionViewModel: BaseViewModel<Session> {
    var expandedSection: Int?
    lazy var startDate: MutableProperty<Date> = {
        return MutableProperty<Date>(Date(timeIntervalSinceMidnight: 0))
    }()
    lazy var endDate: MutableProperty<Date> = {
        return MutableProperty<Date>(Date(timeIntervalSinceMidnight: 0))
    }()
    lazy var sessionLength: SignalProducer<TimeInterval, NoError> = {
        return SignalProducer.combineLatest(self.startDate.producer, self.endDate.producer).map {
            tuple in
            tuple.1.timeIntervalSince(tuple.0)
        }
    }()

    override init() {
        super.init()

        startDate.producer.startWithValues {
            let timeInterval = self.endDate.value.timeIntervalSince($0)
            if timeInterval < 0 {
                self.endDate.swap($0)
            } else if timeInterval > 86400 {
                self.endDate.swap(Calendar.current.date(byAdding: .day, value: 1, to: $0)!)
            }
        }
    }

    override func initialValues(_ session: Session) {

    }

    override func setupBindings(_ session: Session) {

    }
}

class ClassSessionController: UITableViewController {
    let viewModel: ClassSessionViewModel = {
        return ClassSessionViewModel()
    }()
    var session: Session? {
        get {
            return self.viewModel.subject
        }
        set(newSession) {
            self.viewModel.subject = newSession
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        }

        // The animation appears better when rendering the row with 0-height rather than using `tableView.insertRows()`
        // see: http://www.thomashanning.com/how-to-show-and-hide-a-date-picker-from-a-table-view-cell/
        if let expandedSection = self.viewModel.expandedSection {
            if expandedSection == indexPath.section {
                return 180
            }
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! ClassSessionDateValueCell

            if indexPath.section == 0 {
                cell.infoLabel.text = NSLocalizedString("ClassSessionController.sessionStart", comment: "Session Starts at DateTime")

                cell.valueLabel.reactive.text <~ self.viewModel.startDate.map { (date) -> String in
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    formatter.timeStyle = .short

                    return formatter.string(from: date)
                }
            } else if indexPath.section == 1 {
                cell.infoLabel.text = NSLocalizedString("ClassSessionController.sessionDurations", comment: "Session Lasts Duration")

                cell.valueLabel.reactive.text <~ self.viewModel.sessionLength.map { (length) -> String in
                    let formatter = DateComponentsFormatter()
                    formatter.unitsStyle = .full
                    formatter.allowedUnits = [ .hour, .minute ]

                    return formatter.string(from: round(length))!
                }
            }

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as! ClassSessionDatePickerCell

        if indexPath.section == 0 {
            cell.datePicker.date = self.viewModel.startDate.value

            self.viewModel.startDate <~ cell.rac_dateValueSignal
        } else if indexPath.section == 1 {
            cell.datePicker.date = self.viewModel.endDate.value
            cell.datePicker.reactive.makeBindingTarget { $0.minimumDate = $1 } as BindingTarget<Date> <~ self.viewModel.startDate
            cell.datePicker.reactive.makeBindingTarget { $0.maximumDate = $1 } as BindingTarget<Date> <~ self.viewModel.startDate.map({ (startDate) -> Date in
                return Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
            })

            self.viewModel.endDate <~ cell.rac_dateValueSignal
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.viewModel.expandedSection == indexPath.section {
            tableView.beginUpdates()
            self.viewModel.expandedSection = nil
            tableView.endUpdates()

            tableView.deselectRow(at: indexPath, animated: true)

            return
        }

        tableView.beginUpdates()
        self.viewModel.expandedSection = indexPath.section
        tableView.endUpdates()
    }
}

class ClassSessionDateValueCell: UITableViewCell {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}

class ClassSessionDatePickerCell: UITableViewCell {
    var rac_dateValueSignal: Signal<Date, NoError> {
        return self.datePicker.reactive.dates
                .take(until: self.reactive.prepareForReuse)
    }

    @IBOutlet weak var datePicker: UIDatePicker!
}
