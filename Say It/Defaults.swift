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


    private static var _pronunciations: [Pronounciation]?

    static var pronunciations: [Pronounciation] {
        get {
            if let _pronunciations = _pronunciations {
                return _pronunciations
            }

            guard let data = UserDefaults.standard.value(forKey:"pronunciations") as? Data else {
                return []
            }

            let r = (try? PropertyListDecoder().decode([Pronounciation].self, from: data)) ?? []
            _pronunciations = r

            return r
        }

        set {
            _pronunciations = newValue
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: "pronunciations")
        }
    }
}
