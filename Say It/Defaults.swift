//
//  Defaults.swift
//  Say It
//
//  Created by David Albert on 4/6/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Foundation

struct Defaults {
    static var rate: Int {
        get {
            let r = UserDefaults.standard.integer(forKey: "rate")

            return r == 0 ? 225 : r
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

    static var selectedPreferenceTabIdentifier: String? {
        get {
            UserDefaults.standard.string(forKey: "selectedPreferenceTabIdentifier")
        }

        set {
            UserDefaults.standard.set(newValue, forKey: "selectedPreferenceTabIdentifier")
        }
    }

    private static var _pronunciations: [Pronunciation]?

    static var pronunciations: [Pronunciation] {
        get {
            if let _pronunciations = _pronunciations {
                return _pronunciations
            }

            guard let a = UserDefaults.standard.array(forKey: "pronunciations") as? [Dictionary<String, Any>] else {
                return []
            }

            let r = a.compactMap { d in Pronunciation(dictionary: d) }

            _pronunciations = r

            return r
        }

        set {
            _pronunciations = newValue
            UserDefaults.standard.set(newValue.map { $0.toDictionary() }, forKey: "pronunciations")
        }
    }
}
