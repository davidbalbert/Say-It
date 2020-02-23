//
//  Defaults.swift
//  Say It
//
//  Created by David Albert on 4/6/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Foundation

struct Defaults {
    static var rate: Int? {
        get {
            let r = UserDefaults.standard.integer(forKey: "rate")

            return r == 0 ? nil : r
        }

        set {
            UserDefaults.standard.set(newValue, forKey: "rate")
        }
    }

    static var showDock: Bool {
        get {
            UserDefaults.standard.bool(forKey: "showDock")
        }

        set {
            UserDefaults.standard.set(newValue, forKey: "showDock")
        }
    }
}
