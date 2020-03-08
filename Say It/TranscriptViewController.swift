//
//  TranscriptController.swift
//  Say It
//
//  Created by David Albert on 3/5/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class TranscriptViewController: NSSplitViewController {
    var log: [TranscriptEntry] = [] {
        didSet {
            tableViewController.log = log
        }
    }

    var selectedRow: Int = -1 {
        didSet {
            if selectedRow == -1 {
                detailViewController.text = ""
            } else {
                detailViewController.text = log[selectedRow].text
            }
        }
    }

    var tableViewController: TranscriptTableViewController {
        return splitViewItems[0].viewController as! TranscriptTableViewController
    }

    var detailViewController: TranscriptDetailViewController {
        return splitViewItems[1].viewController as! TranscriptDetailViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}
