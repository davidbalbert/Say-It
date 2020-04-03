//
//  Speaker.swift
//  Say It
//
//  Created by David Albert on 4/7/19.
//  Copyright © 2019 David Albert. All rights reserved.
//

import Cocoa

class Speaker : NSObject, NSSpeechSynthesizerDelegate {
    var synth: NSSpeechSynthesizer?

    var skipCompletionHandlersInSynthCallback = false

    var beginHandlers: [UUID: () -> Void] = [:]
    var completionHandlers: [UUID: () -> Void] = [:]

    var rate: Int {
        get {
            return Defaults.rate
        }
    }

    @objc var isSpeaking: Bool {
        return synth?.isSpeaking ?? false
    }

    func addBeginHandler(_ handler: @escaping () -> Void) -> UUID {
        let id = UUID()
        beginHandlers[id] = handler

        return id
    }

    func removeBeginHandler(_ id: UUID) {
        beginHandlers.removeValue(forKey: id)
    }

    func addCompletionHandler(_ handler: @escaping () -> Void) -> UUID {
        let id = UUID()
        completionHandlers[id] = handler

        return id
    }

    func removeCompletionHandler(_ id: UUID) {
        completionHandlers.removeValue(forKey: id)
    }

    func startSpeaking(_ s: String, withoutSubstitutingPronunciations skipSubstitute: Bool = false) {
        if let synth = synth, synth.isSpeaking {
            // speechSynthesizer:didFinishSpeaking: seems to get called asynchronously
            // after we return to the run loop. That would mean if we start speaking
            // when we're already speaking, the order of callbacks would be like this:
            //
            // begin
            // begin
            // completion (immediately after begin)
            // completion
            //
            // to avoid this, and get the right order (begin, completion, begin,
            // completion), we skip the completion handlers in the callback and run
            // them inline here.
            skipCompletionHandlersInSynthCallback = true
            synth.stopSpeaking()
            runCompletionHandlers()
        }

        let synth = NSSpeechSynthesizer()
        synth.delegate = self
        synth.rate = Float(Defaults.rate)
        self.synth = synth

        beginHandlers.values.forEach { handler in
            handler()
        }

        if (skipSubstitute) {
            synth.startSpeaking(s)
        } else {
            synth.startSpeaking(substitutePronunciations(s))
        }
    }

    func substitutePronunciations(_ s: String) ->  String {
        var res = s

        for p in Defaults.pronunciations {
            if (p.isBlank) {
                continue
            }

            res = res.replacingOccurrences(of: p.from, with: p.to)
        }

        return res
    }

    func stopSpeaking() {
        synth?.stopSpeaking()
        synth = nil
    }

    func speechSynthesizer(_ sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool) {
        if skipCompletionHandlersInSynthCallback {
            skipCompletionHandlersInSynthCallback = false
            return
        }

        runCompletionHandlers()
    }

    func runCompletionHandlers() {
        completionHandlers.values.forEach { handler in
            handler()
        }
    }
}
