//
//  PronounciationsViewController.swift
//  Say It
//
//  Created by David Albert on 3/7/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class PronunciationsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, NSControlTextEditingDelegate {
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var addRemove: NSSegmentedControl!
    var justDeleted = false

    var selection = IndexSet() {
        didSet {
            if selection.isEmpty {
                addRemove.setEnabled(false, forSegment: 1)
            } else {
                addRemove.setEnabled(true, forSegment: 1)
            }

            setVisibilityForAllButtons()
        }
    }

    var speakerBeginId: UUID!
    var speakerCompletionId: UUID!
    var speaking = false {
        didSet {
            if speaking {
                setEnabledForAllButtons(false)
            } else {
                setEnabledForAllButtons(true)
            }
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        speakerBeginId = appDelegate.speaker.addBeginHandler { [weak self] in
            self?.speaking = true
        }

        speakerCompletionId = appDelegate.speaker.addCompletionHandler { [weak self] in
            self?.speaking = false
        }


        setVisibilityForAllButtons()
        speaking = appDelegate.speaker.isSpeaking
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        appDelegate.speaker.removeBeginHandler(speakerBeginId)
        appDelegate.speaker.removeCompletionHandler(speakerCompletionId)
    }

    func setEnabledForAllButtons(_ enabled: Bool) {
        for row in 0..<Defaults.pronunciations.count {
            let view = tableView.view(atColumn: 2, row: row, makeIfNecessary: false) as? ButtonTableCellView
            view?.button.isEnabled = enabled
        }
    }

    func setVisibilityForAllButtons() {
        for row in 0..<Defaults.pronunciations.count {
            setVisibilityForButton(at: row)
        }
    }

    func setVisibilityForButton(at row: Int) {
        let p = Defaults.pronunciations[row]
        let visible = selection.contains(row) && !p.from.isEmpty && !p.to.isEmpty
        let view = tableView.view(atColumn: 2, row: row, makeIfNecessary: false) as? ButtonTableCellView

        view?.button.isHidden = !visible
    }

    func setVisibilityForButtonWhileEditing(row: Int, column col: Int, value string: String) {
        guard let view = tableView.view(atColumn: 2, row: row, makeIfNecessary: false) as? ButtonTableCellView else {
            return
        }

        var p = Defaults.pronunciations[row]

        if col == 0 {
            p.from = string
        } else if col == 1 {
            p.to = string
        }

        view.button.isHidden = p.from.isEmpty || p.to.isEmpty
    }


    func numberOfRows(in tableView: NSTableView) -> Int {
        Defaults.pronunciations.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let p = Defaults.pronunciations[row]
        let identifier: String
        let value: String?

        if tableColumn == tableView.tableColumns[0] {
            identifier = "Replace"
            value = p.from
        } else if tableColumn == tableView.tableColumns[1] {
            identifier = "With"
            value = p.to
        } else if tableColumn == tableView.tableColumns[2] {
            identifier = "Test"
            value = nil
        } else {
            return nil
        }

        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: identifier), owner: self) as? NSTableCellView else {
            return nil
        }

        if let value = value {
            cell.textField?.stringValue = value
        }

        return cell
    }

    // Makes sure the "Test" button appears as soon as a row appears selected
    func tableViewSelectionIsChanging(_ notification: Notification) {
        selection = tableView.selectedRowIndexes
    }

    // Makes sure the "Test" button appears when the selection is changed with the keyboard
    func tableViewSelectionDidChange(_ notification: Notification) {
        selection = tableView.selectedRowIndexes
    }

    @IBAction func updateFrom(_ sender: NSTextField) {
        if justDeleted {
            return
        }

        let row = tableView.selectedRow

        var ps = Defaults.pronunciations
        ps[row].from = sender.stringValue
        Defaults.pronunciations = ps

        setVisibilityForButton(at: row)
    }

    @IBAction func updateTo(_ sender: NSTextField) {
        if justDeleted {
            return
        }

        let row = tableView.selectedRow

        var ps = Defaults.pronunciations
        ps[row].to = sender.stringValue
        Defaults.pronunciations = ps

        setVisibilityForButton(at: row)
    }

    func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else {
            return
        }

        guard let fieldEditor = notification.userInfo?["NSFieldEditor"] as? NSText else {
            return
        }

        let row = tableView.selectedRow
        let col = tableView.column(for: textField)

        // Reading textField.stringValue makes the text field forget its original (pre-editing) value
        // and replaces it with the current value of the field editor. This breaks canceling the edit
        // by pressing escape: the new value remains in the textField even though we canceled. Instead,
        // we read the value directly from the field editor.
        setVisibilityForButtonWhileEditing(row: row, column: col, value: fieldEditor.string)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        // Set the button visiblity when the user cancels editing by pressing escape. In this
        // situation, neither controlTextDidChange or controlTextDidEndEditing are triggered.
        if commandSelector == #selector(control.cancelOperation(_:)) {
            let row = tableView.selectedRow
            let col = tableView.column(for: control)
            let p = Defaults.pronunciations[row]

            if col == 0 {
                setVisibilityForButtonWhileEditing(row: row, column: col, value: p.from)
            } else if col == 1 {
                setVisibilityForButtonWhileEditing(row: row, column: col, value: p.to)
            }
        }

        return false
    }

    @IBAction func addOrRemoveRow(_ sender: Any) {
        if addRemove.isSelected(forSegment: 0) {
            var ps = Defaults.pronunciations

            if (ps.isEmpty || !ps.last!.isBlank) {
                ps.append(Pronunciation(from: "", to: ""))
                Defaults.pronunciations = ps

                tableView.insertRows(at: IndexSet(integer: ps.count-1))
            }

            tableView.selectRowIndexes(IndexSet(integer: ps.count-1), byExtendingSelection: false)

            let cell = tableView.rowView(atRow: ps.count-1, makeIfNecessary: false)!.view(atColumn: 0) as! NSTableCellView

            cell.textField?.becomeFirstResponder()
        } else {
            let s = selection

            let a = NSMutableArray(array: Defaults.pronunciations)
            a.removeObjects(at: s)
            Defaults.pronunciations = a as NSArray as! [Pronunciation]

            // HACK: make sure we ignore the text view action that gets fired when we delete a row
            // while we're editing a cell.
            justDeleted = true

            tableView.removeRows(at: s)
            tableView.selectRowIndexes(IndexSet(integer: s.first! - 1), byExtendingSelection: false)

            justDeleted = false
        }
    }

    @IBAction func testPronunciation(_ sender: NSButton) {
        var p: Pronunciation?

        for row in selection {
            let view = tableView.view(atColumn: 2, row: row, makeIfNecessary: false) as? ButtonTableCellView

            if sender == view?.button {
                p = Defaults.pronunciations[row]
                break
            }
        }

        if let p = p {
            // Use speaker.startSpeaking rather than appDelegate.startSpeaking
            // to skip adding to the transcript.
            appDelegate.speaker.startSpeaking("\(p.from). \(p.to).", withoutSubstitutingPronunciations: true)
        }
    }
}
