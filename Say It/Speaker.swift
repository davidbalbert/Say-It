//
//  Speaker.swift
//  Say It
//
//  Created by David Albert on 4/7/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Cocoa
import AVFoundation

import os

final class Speaker: NSObject, AVSpeechSynthesizerDelegate, Sendable {
    struct State {
        let synth: AVSpeechSynthesizer
        var beginHandlers: [UUID: () -> Void] = [:]
        var completionHandlers: [UUID: () -> Void] = [:]
    }

    let state: OSAllocatedUnfairLock<State>
    var rate: Int {
        get {
            return Defaults.rate
        }
    }

    override init() {
        self.state = .init(initialState: .init(synth: AVSpeechSynthesizer()))
        super.init()

        state.withLock {
            $0.synth.delegate = self
        }
    }

    @objc var isSpeaking: Bool {
        state.withLock {
            $0.synth.isSpeaking
        }
    }

    func addBeginHandler(_ handler: @escaping () -> Void) -> UUID {
        let id = UUID()
        state.withLock {
            $0.beginHandlers[id] = handler
        }
        return id
    }

    func removeBeginHandler(_ id: UUID) {
        state.withLock {
            _ = $0.beginHandlers.removeValue(forKey: id)
        }
    }

    func addCompletionHandler(_ handler: @escaping () -> Void) -> UUID {
        let id = UUID()

        state.withLock {
            $0.completionHandlers[id] = handler
        }

        return id
    }

    func removeCompletionHandler(_ id: UUID) {
        state.withLock {
            _ = $0.completionHandlers.removeValue(forKey: id)
        }
    }

    func startSpeaking(_ s: String, withoutSubstitutingPronunciations skipSubstitute: Bool = false) {
        state.withLock {
            if $0.synth.isSpeaking {
                $0.synth.stopSpeaking(at: .immediate)
            }

            let u: AVSpeechUtterance
            if (skipSubstitute) {
                u = AVSpeechUtterance(string: s)
            } else {
                u = AVSpeechUtterance(string: substitutePronunciations(s))
            }
            print("?", AVSpeechUtteranceMinimumSpeechRate, AVSpeechUtteranceDefaultSpeechRate, AVSpeechUtteranceMaximumSpeechRate)
            u.rate = 0.7
            $0.synth.speak(u)
        }
    }

    func substitutePronunciations(_ s: String) ->  String {
        var res = s

        for p in Defaults.pronunciations {
            if (p.isBlank) {
                continue
            }

            res = res.replacingOccurrences(of: p.from, with: p.to, options: p.caseSensitive ? [] : .caseInsensitive)
        }

        return res
    }

    func stopSpeaking() {
        state.withLock {
            _ = $0.synth.stopSpeaking(at: .immediate)
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("didStart")
        state.withLock {
            for handler in $0.beginHandlers.values {
                handler()
            }
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("didFinish")
        state.withLock {
            for handler in $0.completionHandlers.values {
                handler()
            }
        }
    }
}
