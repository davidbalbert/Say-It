//
//  TableViewController.swift
//  Say It
//
//  Created by David Albert on 3/7/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class TranscriptTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView: NSTableView!

    var log: [TranscriptEntry] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        log.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let entry = log[row]
        let identifier: String
        let value: Any

        if tableColumn == tableView.tableColumns[0] {
            identifier = "TimestampCell"
            value = entry.date
        } else if tableColumn == tableView.tableColumns[1] {
            identifier = "TextCell"
            value = entry.text
        } else {
            return nil
        }

        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: identifier), owner: nil) as? NSTableCellView else {
            return nil
        }

        cell.textField?.objectValue = value

        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        (parent as! TranscriptViewController).selectedRow = tableView.selectedRow
    }

}
