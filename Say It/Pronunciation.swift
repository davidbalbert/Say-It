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

    init(from: String, to: String) {
        self.from = from
        self.to = to
    }

    init?(dictionary: [String: String]) {
        guard let from = dictionary["from"], let to = dictionary["to"] else {
            return nil
        }

        self.from = from
        self.to = to
    }

    func toDictionary() -> [String:String] {
        return [
            "from": from,
            "to": to
        ]
    }
}
