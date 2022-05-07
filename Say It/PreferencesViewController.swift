//
//  PreferencesController.swift
//  Say It
//
//  Created by David Albert on 3/2/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSTabViewController {
    override func viewDidLoad() {
        // Super.viewDidLoad() selects tabIndex 0, which will overwrite
        // our saved preference. Load the preference, then call super,
        // and finally, restore the preference.
        let i = Defaults.selectedPreferenceTabIndex

        super.viewDidLoad()

        if (i < tabViewItems.count) {
            selectedTabViewItemIndex = i
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        guard let view = tabView.selectedTabViewItem?.view else {
            return
        }

        guard let window = view.window else {
            return
        }

        guard let frame = frame(of: window, for: view) else {
            return
        }

        view.window?.setFrame(frame, display: false)
    }

    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, willSelect: tabViewItem)

        guard let window = view.window else {
            return
        }

        guard let oldView = tabView.selectedTabViewItem?.view, let newView = tabViewItem?.view  else {
            return
        }

        guard let newFrame = frame(of: window, for: newView) else {
            return
        }

        oldView.isHidden = true
        newView.isHidden = true

        window.setFrame(newFrame, display: false, animate: true)
    }

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)

        tabViewItem?.view?.isHidden = false

        Defaults.selectedPreferenceTabIndex = selectedTabViewItemIndex

        if let title = title {
            view.window?.title = title
        }
    }

    func frame(of window: NSWindow, for view: NSView) -> NSRect? {
        let contentSize = view.fittingSize
        let newFrame = window.frameRect(forContentRect: NSRect(origin: .zero, size: contentSize))
        let oldFrame = window.frame
        let newSize = newFrame.size
        let oldSize = oldFrame.size

        var frame = window.frame
        frame.size = newSize
        frame.origin.y -= (newSize.height - oldSize.height)

        return frame
    }
}
