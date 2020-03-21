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
        // our saved preference. Load the preference
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

        sizeWindowContentToContent(of: view, animate: false)
    }

    override func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, willSelect: tabViewItem)

        guard let oldView = tabView.selectedTabViewItem?.view, let newView = tabViewItem?.view  else {
            return
        }

        oldView.isHidden = true
        newView.isHidden = true

        sizeWindowContentToContent(of: newView, animate: true)
    }

    override func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelect: tabViewItem)

        tabViewItem?.view?.isHidden = false

        Defaults.selectedPreferenceTabIndex = selectedTabViewItemIndex

        if let title = title {
            view.window?.title = title
        }
    }

    func sizeWindowContentToContent(of newView: NSView, animate: Bool) {
        guard let window = view.window else {
            return
        }

        let contentSize = newView.fittingSize
        let newWindowSize = window.frameRect(forContentRect: NSRect(origin: NSPoint.zero, size: contentSize)).size

        var frame = window.frame
        frame.origin.y += frame.size.height
        frame.origin.y -= newWindowSize.height
        frame.size = newWindowSize

        window.setFrame(frame, display: false, animate: animate)
    }
}
