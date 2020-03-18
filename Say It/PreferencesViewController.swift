//
//  PreferencesController.swift
//  Say It
//
//  Created by David Albert on 3/2/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSTabViewController {
    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)

        view.window?.title = title ?? "Preferences"
    }

    override func transition(from fromViewController: NSViewController, to toViewController: NSViewController, options: NSViewController.TransitionOptions = [], completionHandler completion: (() -> Void)? = nil) {

        NSAnimationContext.runAnimationGroup { context in
            updateWindowFrame(from: fromViewController, to: toViewController)

            super.transition(from: fromViewController, to: toViewController, options: options, completionHandler: completion)
        }
    }

    func updateWindowFrame(from fromViewController: NSViewController, to toViewController: NSViewController) {
        guard let window = view.window else {
            return
        }

        let oldsz = fromViewController.view.frame.size
        let newsz = toViewController.view.frame.size
        let diff = NSSize(width: newsz.width - oldsz.width, height: newsz.height - oldsz.height)

        let oldFrame = window.frame
        let newOrigin = NSPoint(x: oldFrame.origin.x, y: oldFrame.origin.y - diff.height)
        let newFrame = NSRect(origin: newOrigin, size: NSSize(width: oldFrame.size.width + diff.width, height: oldFrame.size.height + diff.height))

        window.animator().setFrame(newFrame, display: false)
    }
}
