//
//  PronunciationsViewController.swift
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
            setVisibilityForButton(at: row, pronunciation: Defaults.pronunciations[row])
        }
    }

    func setVisibilityForButton(at row: Int, pronunciation p: Pronunciation) {
        let visible = selection.contains(row) && !p.from.isEmpty && !p.to.isEmpty
        let view = tableView.view(atColumn: 2, row: row, makeIfNecessary: false) as? ButtonTableCellView

        view?.button.isHidden = !visible
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

    // If you're editing a text field when you click a column, make sure the edit finishes
    // before the row is deselected. This prevents a crash.
    func tableView(_ tableView: NSTableView, mouseDownInHeaderOf tableColumn: NSTableColumn) {
        view.window?.makeFirstResponder(tableView)
    }

    // Make sure the "Test" button appears as soon as a row appears selected
    func tableViewSelectionIsChanging(_ notification: Notification) {
        selection = tableView.selectedRowIndexes
    }

    // Make sure the "Test" button appears when the selection is changed with the keyboard
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
    }

    @IBAction func updateTo(_ sender: NSTextField) {
        if justDeleted {
            return
        }

        let row = tableView.selectedRow

        var ps = Defaults.pronunciations
        ps[row].to = sender.stringValue
        Defaults.pronunciations = ps
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
        var p = Defaults.pronunciations[row]

        // Reading textField.stringValue makes the text field forget its original (pre-editing) value
        // and replaces it with the current value of the field editor. This breaks canceling the edit
        // by pressing escape: the new value remains in the textField even though we canceled. Instead,
        // we read the value directly from the field editor.
        if col == 0 {
            p.from = fieldEditor.string
        } else if col == 1 {
            p.to = fieldEditor.string
        }

        setVisibilityForButton(at: row, pronunciation: p)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        // Set the button visibility when the user cancels editing by pressing escape. In this
        // situation, controlTextDidEndEditing are triggered, so we use this method instead.
        if commandSelector == #selector(control.cancelOperation(_:)) {
            let row = tableView.selectedRow
            setVisibilityForButton(at: row, pronunciation: Defaults.pronunciations[row])
        }

        return false
    }

    override func keyDown(with event: NSEvent) {
        let delete = Character(UnicodeScalar(NSDeleteCharacter)!)

        if event.charactersIgnoringModifiers?.first == delete && !selection.isEmpty {
            removeSelectedRows()
        } else {
            super.keyDown(with: event)
        }
    }

    @IBAction func addOrRemoveRow(_ sender: Any) {
        if addRemove.isSelected(forSegment: 0) {
            addRowIfNecessary()
        } else {
            removeSelectedRows()
        }
    }

    func addRowIfNecessary() {
        var ps = Defaults.pronunciations

        if (ps.isEmpty || !ps.last!.isBlank) {
            let i = IndexSet(integer: ps.count)
            addRows([Pronunciation(from: "", to: "")], at: i)
        }

        ps = Defaults.pronunciations

        tableView.selectRowIndexes(IndexSet(integer: ps.count-1), byExtendingSelection: false)

        guard let view = tableView.view(atColumn: 0, row: ps.count-1, makeIfNecessary: false) as? NSTableCellView else {
            return
        }

        if view.textField?.acceptsFirstResponder ?? false {
            view.window?.makeFirstResponder(view.textField)
        }
    }

    func removeSelectedRows() {
        let s = selection

        // HACK: make sure we ignore the textField's action that gets fired when we delete a row
        // while we're editing a cell.
        justDeleted = true

        removeRows(at: s)
        tableView.selectRowIndexes(IndexSet(integer: s.first! - 1), byExtendingSelection: false)

        justDeleted = false
    }

    func addRows(_ rows: [Pronunciation], at indexes: IndexSet) {
        var ps = Defaults.pronunciations

        for (i, p) in zip(indexes, rows) {
            ps.insert(p, at: i)
        }

        Defaults.pronunciations = ps

        tableView.insertRows(at: indexes)

        undoManager?.registerUndo(withTarget: self) { target in
            target.removeRows(at: indexes)
        }
    }

    func removeRows(at indexes: IndexSet) {
        let a = NSMutableArray(array: Defaults.pronunciations)

        let removed = a.objects(at: indexes) as! [Pronunciation]
        a.removeObjects(at: indexes)

        Defaults.pronunciations = a as NSArray as! [Pronunciation]

        tableView.removeRows(at: indexes)

        undoManager?.registerUndo(withTarget: self) { target in
            target.addRows(removed, at: indexes)
            self.tableView.selectRowIndexes(indexes, byExtendingSelection: false)
        }
    }

    // (clickedRow, clickedColumn)
    //
    // (-1, -1) -> background
    // (-1, m)  -> header column m
    // (n, m)   -> row n, column m
    @IBAction func handleDoubleClick(_ sender: NSTableView) {
        let row = tableView.clickedRow
        let col = tableView.clickedColumn

        if row == -1 && col == -1 {
            addRowIfNecessary()
        } else if let event = NSApp.currentEvent, row > -1 {
            edit(row: row, column: col, with: event)
        }
    }

    func edit(row: Int, column col: Int, with event: NSEvent) {
        guard let cellView = tableView.view(atColumn: col, row: row, makeIfNecessary: false) as? NSTableCellView else {
            return
        }

        if let cellView = cellView as? ButtonTableCellView {
            guard let p = cellView.superview?.convert(event.locationInWindow, from: nil) else {
                return
            }

            if let button = cellView.hitTest(p) as? NSButton {
                button.performClick(self)
            }
        } else {
            view.window?.makeFirstResponder(cellView.textField)
        }
    }

    @IBAction func testPronunciation(_ sender: NSButton) {
        // If we're editing a cell when we click the test button,
        // make sure to stop editing.
        view.window?.makeFirstResponder(tableView)

        for row in selection {
            let view = tableView.view(atColumn: 2, row: row, makeIfNecessary: false) as? ButtonTableCellView

            if sender == view?.button {
                let p = Defaults.pronunciations[row]

                // Use speaker.startSpeaking rather than appDelegate.startSpeaking
                // to skip adding to the transcript.
                appDelegate.speaker.startSpeaking("\(p.from). \(p.to).", withoutSubstitutingPronunciations: true)

                return
            }
        }
    }
}
