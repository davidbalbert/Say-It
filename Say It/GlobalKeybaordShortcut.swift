//
//  GlobalKeybaordShortcut.swift
//  Say It
//
//  Created by David Albert on 2/9/20.
//  Copyright © 2020 David Albert. All rights reserved.
//

import Carbon

extension FourCharCode {
    static func from(string s: String) -> FourCharCode? {
        if s.count != 4 || s.lengthOfBytes(using: .utf8) != 4 {
            return nil
        }

        var result: FourCharCode = 0

        for c in s.utf8 {
            result = (result << 8) + FourCharCode(c)
        }

        return result
    }
}

class GlobalKeyboardShortcut {
    enum Key {
        case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
        case zero, one, two, three, four, five, six, seven, eight, nine
        case equal, minus, rightBracket, leftBracket, quote, semicolon, backslash, comma, slash, period, grave
        case `return`, tab, space, delete, escape, help, home, pageUp, forwardDelete, end, pageDown, left, right, down, up

        var keycode: UInt32 {
            switch self {
            case .a: return UInt32(kVK_ANSI_A)
            case .b: return UInt32(kVK_ANSI_B)
            case .c: return UInt32(kVK_ANSI_C)
            case .d: return UInt32(kVK_ANSI_D)
            case .e: return UInt32(kVK_ANSI_E)
            case .f: return UInt32(kVK_ANSI_F)
            case .g: return UInt32(kVK_ANSI_G)
            case .h: return UInt32(kVK_ANSI_H)
            case .i: return UInt32(kVK_ANSI_I)
            case .j: return UInt32(kVK_ANSI_J)
            case .k: return UInt32(kVK_ANSI_K)
            case .l: return UInt32(kVK_ANSI_L)
            case .m: return UInt32(kVK_ANSI_M)
            case .n: return UInt32(kVK_ANSI_N)
            case .o: return UInt32(kVK_ANSI_O)
            case .p: return UInt32(kVK_ANSI_P)
            case .q: return UInt32(kVK_ANSI_Q)
            case .r: return UInt32(kVK_ANSI_R)
            case .s: return UInt32(kVK_ANSI_S)
            case .t: return UInt32(kVK_ANSI_T)
            case .u: return UInt32(kVK_ANSI_U)
            case .v: return UInt32(kVK_ANSI_V)
            case .w: return UInt32(kVK_ANSI_W)
            case .x: return UInt32(kVK_ANSI_X)
            case .y: return UInt32(kVK_ANSI_Y)
            case .z: return UInt32(kVK_ANSI_Z)

            case .zero:  return UInt32(kVK_ANSI_0)
            case .one:   return UInt32(kVK_ANSI_1)
            case .two:   return UInt32(kVK_ANSI_2)
            case .three: return UInt32(kVK_ANSI_3)
            case .four:  return UInt32(kVK_ANSI_4)
            case .five:  return UInt32(kVK_ANSI_5)
            case .six:   return UInt32(kVK_ANSI_6)
            case .seven: return UInt32(kVK_ANSI_7)
            case .eight: return UInt32(kVK_ANSI_8)
            case .nine:  return UInt32(kVK_ANSI_9)

            case .equal: return UInt32(kVK_ANSI_Equal)
            case .minus: return UInt32(kVK_ANSI_Minus)
            case .rightBracket: return UInt32(kVK_ANSI_RightBracket)
            case .leftBracket: return UInt32(kVK_ANSI_LeftBracket)
            case .quote: return UInt32(kVK_ANSI_Quote)
            case .semicolon: return UInt32(kVK_ANSI_Semicolon)
            case .backslash: return UInt32(kVK_ANSI_Backslash)
            case .comma: return UInt32(kVK_ANSI_Comma)
            case .slash: return UInt32(kVK_ANSI_Slash)
            case .period: return UInt32(kVK_ANSI_Period)
            case .grave: return UInt32(kVK_ANSI_Grave)

            case .return: return UInt32(kVK_Return)
            case .tab: return UInt32(kVK_Tab)
            case .space: return UInt32(kVK_Space)
            case .delete: return UInt32(kVK_Delete)
            case .escape: return UInt32(kVK_Escape)

            case .help: return UInt32(kVK_Help)
            case .home: return UInt32(kVK_Home)
            case .pageUp: return UInt32(kVK_PageUp)
            case .forwardDelete: return UInt32(kVK_ForwardDelete)
            case .end: return UInt32(kVK_End)
            case .pageDown: return UInt32(kVK_PageDown)

            case .left: return UInt32(kVK_LeftArrow)
            case .right: return UInt32(kVK_RightArrow)
            case .up: return UInt32(kVK_UpArrow)
            case .down: return UInt32(kVK_DownArrow)
            }
        }
    }

    struct Modifiers: OptionSet {
        let rawValue: UInt32

        static let command = Modifiers(rawValue: UInt32(cmdKey))
        static let shift   = Modifiers(rawValue: UInt32(shiftKey))
        static let option  = Modifiers(rawValue: UInt32(optionKey))
        static let control = Modifiers(rawValue: UInt32(controlKey))
    }

    var eventHotKey: EventHotKeyRef?
    var carbonEventHandler: EventHandlerRef?
    let id: EventHotKeyID

    let key: Key
    let modifiers: Modifiers
    let handler: (GlobalKeyboardShortcut) -> Void

    var enabled: Bool {
        carbonEventHandler != nil
    }

    static var nextId: UInt32 = 1

    init(key: Key, modifiers: Modifiers, handler: @escaping (GlobalKeyboardShortcut) -> Void) {
        self.key = key
        self.modifiers = modifiers
        self.handler = handler

        id = EventHotKeyID(signature: FourCharCode.from(string: "GKSs")!, id: GlobalKeyboardShortcut.nextId)

        GlobalKeyboardShortcut.nextId += 1

        enable()
    }

    deinit {
        disable()
    }

    func enable() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(GetApplicationEventTarget(), handleGlobalKeyboardShortcut, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &carbonEventHandler)

        RegisterEventHotKey(key.keycode, modifiers.rawValue, id, GetApplicationEventTarget(), 0, &eventHotKey)
    }

    func disable() {
        if let carbonEventHandler = carbonEventHandler {
            RemoveEventHandler(carbonEventHandler)
            self.carbonEventHandler = nil
        }

        if let eventHotKey = eventHotKey {
            UnregisterEventHotKey(eventHotKey)
            self.eventHotKey = nil
        }
    }

    func checkAndHandleEvent(_ event: EventRef?) -> OSStatus {
        guard let event = event else {
            return OSStatus(eventNotHandledErr)
        }

        var eventId = EventHotKeyID()
        let error = GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &eventId)

        if error != noErr {
            return error
        }

        if eventId.signature != id.signature || eventId.id != id.id {
            return OSStatus(eventNotHandledErr)
        }

        handler(self)
        return noErr
    }
}

private func handleGlobalKeyboardShortcut(eventHandlerCall: EventHandlerCallRef?, event: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {

    let shortcut = Unmanaged<GlobalKeyboardShortcut>.fromOpaque(userData!).takeUnretainedValue()

    return shortcut.checkAndHandleEvent(event)
}
