//
//  Pronounciation.swift
//  Say It
//
//  Created by David Albert on 3/12/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

struct Pronunciation : Equatable {
    var from: String
    var to: String
    var caseSensitive: Bool

    var isBlank: Bool {
        from == "" && to == ""
    }

    init(from: String, to: String, caseSensitive: Bool) {
        self.from = from
        self.to = to
        self.caseSensitive = caseSensitive
    }

    init?(dictionary: [String: Any]) {
        guard let from = dictionary["from"] as? String, let to = dictionary["to"] as? String else {
            return nil
        }

        self.from = from
        self.to = to
        self.caseSensitive = dictionary["caseSensitive"] as? Bool ?? false
    }

    func toDictionary() -> [String:Any] {
        return [
            "from": from,
            "to": to,
            "caseSensitive": caseSensitive,
        ]
    }
}
