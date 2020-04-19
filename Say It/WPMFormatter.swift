//
//  WPMFormatter.swift
//  Say It
//
//  Created by David Albert on 4/18/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Foundation

class WPMFormatter : Formatter {
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {

        let s = Scanner(string: string)
        guard let n = s.scanInt() else {
            error?.pointee = "Could't read an Int"
            return false
        }


        if !s.isAtEnd && s.scanString("WPM") == nil {
            error?.pointee = "Found unit other than WPM"
            return false
        }

        obj?.pointee = NSNumber(value: n)
        return true
    }

    override func string(for obj: Any?) -> String? {
        if let n = obj as? Int {
            return "\(n) WPM"
        } else {
            return nil
        }
    }
}
