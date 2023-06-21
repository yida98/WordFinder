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
        return prs.filter { $0.mw != nil }
    }
    
    func allPronunciationURLs() -> [URL] {
        return allPronunciations().compactMap { $0.pronunciationURL() }
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
