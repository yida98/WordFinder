//
//  MWEntry_ext.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/20/23.
//

import Foundation
import SwiftUI

extension MWRetrieveGroup: Equatable {
    func allPronunciations() -> [MWPronunciation] {
        let nonuniquePronunciations = entries.flatMap { $0.allPronunciations() }
        var uniquePronunciationsSet = Set<MWPronunciation>()
        return nonuniquePronunciations.reduce([MWPronunciation]()) { valueSoFar, newValue in
            if uniquePronunciationsSet.contains(newValue) {
                return valueSoFar
            } else {
                var result = valueSoFar
                result.append(newValue)
                uniquePronunciationsSet.insert(newValue)
                return result
            }
        }
    }
    
    func allPronunciationURLs() -> [URL] {
        entries.flatMap { $0.allPronunciationURLs() }
    }
    
    func functionLabel(at index: Int) -> String? {
        entries[index].fl
    }
    
    func allInflectionLabels() -> String {
        entries.flatMap { $0.inflectionLabel() }.compactMap { $0 }.joined(separator: "; ")
    }
    
    func allSenses() -> [MWSenseSequence.Element.Sense] {
        entries.flatMap { $0.allSenses() }
    }
    
    var hasSense: Bool {
        !allSenses().isEmpty
    }
    
    func allShortDefs() -> [String] {
        entries.compactMap { $0.shortdef }.flatMap { $0 }
    }
    
    func allEtymology() -> [(String, MWEtymology)] {
        entries.compactMap {
            guard let fl = $0.fl, let et = $0.et else { return nil }
            return (fl, et)
        }
    }
    
    static func ==(lhs: MWRetrieveGroup, rhs: MWRetrieveGroup) -> Bool {
        lhs.id == rhs.id
    }
}

extension MWRetrieveEntry {
    
    func allPronunciations() -> [MWPronunciation] {
        guard let prs = hwi.prs else { return [] }
        return prs.compactMap { $0 }
    }
    
    func allPronunciationURLs() -> [URL] {
        return allPronunciations().compactMap { $0.pronunciationURL() }
    }
    
    func allInflections() -> ins {
        guard let ins = ins else { return [] }
        return ins.compactMap { $0 }
    }
    
    func inflectionLabel() -> String? {
        guard let ins = ins else { return nil }
        return MWInflections.joinedLabel(ins: ins)
    }
    
    func allSenses() -> [MWSenseSequence.Element.Sense] {
        guard let def = def else { return [] }
        return def.flatMap { $0.allSenses() }
    }
    
    var hasSense: Bool {
        allSenses().count > 0
    }
}

extension MWCognateCrossReferences {
    static func crossReferenceLabel(_ cxs: cxs) -> String {
        cxs.compactMap { reference in
            var text = ""
            if let cxl = reference.cxl {
                text.append("*\(cxl)* ")
            }
            if let cxtis = reference.cxtis {
                text.append(cxtis.compactMap { target in
                    var targetText = ""
                    if let cxl = target.cxl {
                        targetText.append("*\(cxl)* ")
                    }
                    if let cxt = target.cxt {
                        targetText.append(cxt.uppercased())
                    }
                    return targetText.isEmpty ? nil : targetText
                }.joined(separator: ", "))
            }
            return text.isEmpty ? nil : text
        }.joined(separator: ", ")
    }
}

extension MWPronunciation {
    var writtenPronunciation: String? {
        var writtenPronunciation = ""
        
        if let leading = l {
            writtenPronunciation.append(leading)
        }
        if let mw = mw {
            writtenPronunciation.append(mw)
        }
        if let trailing = l2 {
            writtenPronunciation.append(trailing)
        }
        
        return writtenPronunciation.isEmpty ? nil : writtenPronunciation
    }
    
    func pronunciationURL() -> URL? {
        guard let audioFile = audioFile else { return nil }
        return URL(string: audioFile)
    }
    
    var audioFile: String? {
        let languageCode = "en"
        let countryCode = "us"
        let format = "wav"
        
        guard let baseFilename = sound?.audio, let subdirectoryChar = baseFilename.first else { return nil }
        var subdirectory = String(subdirectoryChar)
        if let writtenPronunciation = writtenPronunciation {
            if writtenPronunciation.hasPrefix("bix") {
                subdirectory = "bix"
            } else if writtenPronunciation.hasPrefix("gg") {
                subdirectory = "gg"
            } else if let firstChar = writtenPronunciation.first, firstChar.isNumber || firstChar.isPunctuation {
                subdirectory = "number"
            }
        }
        
        return "https://media.merriam-webster.com/audio/prons/\(languageCode)/\(countryCode)/\(format)/\(subdirectory)/\(baseFilename).\(format)"
    }
    
    var hasAudio: Bool {
        return sound?.audio != nil
    }
}

extension MWPronunciation: Hashable {
    static func == (lhs: MWPronunciation, rhs: MWPronunciation) -> Bool {
        lhs.mw == rhs.mw
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(mw)
    }
}

extension MWDefinition {
    func allSenses() -> [MWSenseSequence.Element.Sense] {
        guard let sseq = sseq else { return [] }
        return sseq.reduce([]) { currResult, newSseq in
            var newArray = currResult
            newArray.append(contentsOf: newSseq.allSenses())
            return newArray
        }
    }
}

extension MWVariant {
    static func joinedLabel(vrs: vrs) -> String {
        let labels = vrs.compactMap { variant in
            var output = "**" + variant.va + "**"
            if let variantLabel = variant.vl {
                output = variantLabel + " " + output
            }
            return output
        }
        return labels.joined(separator: " ")
    }
}

extension MWInflections {
    static func joinedLabel(ins: ins) -> String {
        return ins.reduce("") { resultsSoFar, nextInflection in
            var tempResult = ""
            
            var joiningSeparator = ""
            
            if !resultsSoFar.isEmpty {
                joiningSeparator = "; "
            }
            
            if let label = nextInflection.il {
                tempResult.append("*" + label + "*")
                tempResult.append(" ")
                joiningSeparator = " "
            }
            if let fullInfection = nextInflection.if {
                tempResult.append("**" + fullInfection + "**")
            }
            
            tempResult = resultsSoFar + joiningSeparator + tempResult
            return tempResult
        }
    }
}

extension MWEtymology {
    func textValue() -> String {
        guard case .text(let etymologyText) = content[0] else { debugPrint("This will never happen"); return "" }
        return etymologyText
    }
}

// MARK: - MWSenseSequence

extension MWSenseSequence {
    func allSenses() -> [MWSenseSequence.Element.Sense] {
        var results = [MWSenseSequence.Element.Sense]()
        for sense in senses {
            switch sense {
            case .sense(let sense):
                results.append(sense)
            case .pseq(let pseq):
                results.append(contentsOf: pseq.allSenses())
            case .sen(_):
                results
            case .bs(let bs):
                results.append(bs)
            }
        }
        return results
    }
}

extension MWSenseSequence.Element.Sen {
    func inlineStringDisplay() -> String {
        var allLabels = [String]()
        
        if let et = et {
            allLabels.append(et.textValue())
        }
        if let ins = ins, let inflection = ins.if {
            allLabels.append(inflection)
        }
        if let lbs = lbs {
            let joinedLabels = lbs.joined(separator: ", ")
            allLabels.append(joinedLabels)
        }
        if let sgram = sgram {
            let italicized = "*" + sgram + "*"
            allLabels.append(italicized)
        }
        if let sls = sls {
            let joinedLabels = sls.compactMap { $0.label }.joined(separator: ", ")
            allLabels.append(joinedLabels)
        }
        if let vrs = vrs {
            allLabels.append(MWVariant.joinedLabel(vrs: vrs))
        }
        let output = "[" + allLabels.joined(separator: "; ") + "]"
        return output
    }
}

extension MWSenseSequence.SDSense {
    func fullLabel() -> String {
        "\(sd) \(dt.text)"
    }
}

extension MWSenseSequence.DefiningText.UsageNotes {    
    var flatNoteValues: [String] {
        return notes.flatMap {
            $0.values.compactMap {
                switch $0 {
                case .textValue(let value):
                    return value
                case .vis(_):
                    return nil
                }
            }
        }
    }
}

extension MWSenseSequence.DefiningText.CalledAlsoNote {
    func label() -> String? {
        var text = ""
        
        if let intro = intro {
            text.append("\(intro) ")
        }
        if let cats = cats {
            text.append("*\(cats.compactMap { $0.cat }.joined(separator: ", "))*")
        }
        
        return text.isEmpty ? nil : "\u{2014} \(text)"
    }
}
