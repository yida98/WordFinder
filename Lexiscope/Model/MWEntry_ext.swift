//
//  MWEntry_ext.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/20/23.
//

import Foundation


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
}

extension MWPronunciation {
    var writtenPronunciation: String? { mw }
    
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

extension MWDefinition {
    
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

extension MWSenseSequence.Element.SenseContainer.Element.Sen {
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
            let italicized = "*" + sgram.sgram + "*"
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
