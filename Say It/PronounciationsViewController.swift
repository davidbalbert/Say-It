//
//  PronounciationsViewController.swift
//  Say It
//
//  Created by David Albert on 3/7/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa
import os.log

struct Pronounciation {
    var from: String
    var to: String
}

class PronounciationsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var addRemove: NSSegmentedControl!

    var selection = IndexSet() {
        didSet {
            if selection.isEmpty {
                addRemove.setEnabled(false, forSegment: 1)
            } else {
                addRemove.setEnabled(true, forSegment: 1)
            }
        }
    }

    var pronounciations: [Pronounciation] = [Pronounciation(from: "Foo", to: "Bar"), Pronounciation(from: "Baz", to: "Qux")]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        pronounciations.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let p = pronounciations[row]
        let identifier: String
        let value: String

        if tableColumn == tableView.tableColumns[0] {
            identifier = "Replace"
            value = p.from
        } else if tableColumn == tableView.tableColumns[1] {
            identifier = "With"
            value = p.to
        } else {
            return nil
        }

        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: identifier), owner: self) as? NSTableCellView else {
            return nil
        }

        cell.textField?.stringValue = value

        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        selection = tableView.selectedRowIndexes
    }

    @IBAction func updateFrom(_ sender: NSTextField) {
        if selection.count > 1 {
            os_log("updateFrom called with multiple rows selected [%@]", log: .default, type: .error, Array(selection).map { String($0) }.joined(separator: ", "))
            return
        }

        let row = tableView.selectedRow

        pronounciations[row].from = sender.stringValue
    }

    @IBAction func updateTo(_ sender: NSTextField) {
        if selection.count > 1 {
            os_log("updateTo called with multiple rows selected [%@]", log: .default, type: .error, Array(selection).map { String($0) }.joined(separator: ", "))
            return
        }

        let row = tableView.selectedRow

        pronounciations[row].to = sender.stringValue
    }

    @IBAction func addOrRemoveRow(_ sender: Any) {
        if addRemove.isSelected(forSegment: 0) {
            print("add")
        } else {
            tableView.removeRows(at: selection, withAnimation: .slideUp)

            let a = NSMutableArray(array: pronounciations)
            a.removeObjects(at: selection)
            pronounciations = a as NSArray as! [Pronounciation]
        }
    }
}
