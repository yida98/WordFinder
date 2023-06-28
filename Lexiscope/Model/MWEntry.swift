//
//  MWEntry.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/2/23.
//

import Foundation

struct MWRetrieveEntries: DictionaryRetrieveEntry {
    let entries: [MWRetrieveGroup]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.entries = MWRetrieveEntries.disambiguateEntries((try container.decode([MWRetrieveEntry].self)))
    }
    
    static func disambiguateEntries(_ entries: [MWRetrieveEntry]) -> [MWRetrieveGroup] {
        var disambiguatedEntries = [MWRetrieveGroup]()
        
        var currGroupEntries = [MWRetrieveEntry]()
        var prevHeadword: String?
        for entry in entries {
            if let hw = prevHeadword {
                if hw.lowercased() == entry.hwi.hw.lowercased() {
                    currGroupEntries.append(entry)
                } else {
                    let newGroup = MWRetrieveGroup(headword: hw, entries: currGroupEntries)
                    disambiguatedEntries.append(newGroup)
                    currGroupEntries = [entry]
                    prevHeadword = entry.hwi.hw
                }
            } else {
                prevHeadword = entry.hwi.hw
                currGroupEntries.append(entry)
            }
        }
        if let hw = prevHeadword {
            let newGroup = MWRetrieveGroup(headword: hw, entries: currGroupEntries)
            disambiguatedEntries.append(newGroup)
        }
        
        return disambiguatedEntries
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        var encodingEntries = [MWRetrieveEntry]()
        for entry in entries {
            encodingEntries.append(contentsOf: entry.entries)
        }
        
        try container.encode(encodingEntries)
    }
    
    static var tokenMap: [String: String] { ["{b}": "**", "{\u{005C}/b}": "**", "{/b}": "**",
                                             "{bc}": "**:** ",
                                             "{inf}": "_", "{\u{005C}/inf}": "_", "{/inf}": "_",
                                             "{it}": "*", "{\u{005C}/it}": "*", "{/it}": "*",
                                             "{ldquo}": "\u{201C}", "{rdquo}": "\u{201D}",
                                             "{sc}": "`", "{\u{005C}/sc}": "`", "{/sc}": "`",
                                             "{sup}": "^", "{\u{005C}/sup}": "^", "{/sup}": "^",
                                             "{gloss}": "\u{FF3B}", "{\u{005C}/gloss}": "\u{FF3D}", "{/gloss}": "\u{FF3D}",
                                             "{phrase}": "***", "{\u{005C}/phrase}": "***", "{/phrase}": "***",
                                             "{dx}": "\u{2014} ", "{\u{005C}/dx}": "", "{/dx}": "",
                                             "{dx_def}": "\u{FF08}", "{\u{005C}/dx_def}": "\u{FF09}", "{/dx_def}": "\u{FF09}",
                                             "{dx_ety}": "\u{2014} ", "{\u{005C}/dx_ety}": "", "{/dx_ety}": "",
                                             "{ma}": "\u{2014} more at ", "{\u{005C}/ma}": "", "{/ma}": ""]
    }
}

struct MWRetrieveGroup: DictionaryHeadword, Identifiable {
    var headword: String
    var entries: [MWRetrieveEntry]
    var id: String { entries.first?.meta.uuid ?? headword }
    
    func getWord() -> String { headword }
}

struct MWRetrieveEntry: Codable, Identifiable {
    let meta: MWMeta
    let hom: Int?
    let hwi: MWHeadwordInformation
    /// Functional label e.g. "noun", "adjective"
    let fl: String?
    let ins: ins?
    let cxs: cxs?
    let def: def?
    /// General labels e.g. typically capitalized, used as an attributive noun
    let lbs: lbs?
    let shortdef: shortdef?
    let et: MWEtymology?
    
    enum CodingKeys: String, CodingKey {
        case meta
        case hom
        case hwi
        case fl
        case ins
        case cxs
        case def
        case lbs
        case shortdef
        case et
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.meta = try container.decode(MWMeta.self, forKey: .meta)
        self.hom = try container.decodeIfPresent(Int.self, forKey: .hom)
        self.hwi = try container.decode(MWHeadwordInformation.self, forKey: .hwi)
        self.fl = try container.decodeIfPresent(String.self, forKey: .fl)
        self.ins = try container.decodeIfPresent(Array<MWInflections>.self, forKey: .ins)
        self.cxs = try container.decodeIfPresent(Array<MWCognateCrossReferences>.self, forKey: .cxs)
        self.def = try container.decodeIfPresent(Array<MWDefinition>.self, forKey: .def)
        self.lbs = try container.decodeIfPresent(Array<String>.self, forKey: .lbs)
        self.shortdef = try container.decodeIfPresent(Array<String>.self, forKey: .shortdef)
        self.et = try container.decodeIfPresent(MWEtymology.self, forKey: .et)
    }
    
    func getWord() -> String { hwi.hw }
    
    static func == (lhs: MWRetrieveEntry, rhs: MWRetrieveEntry) -> Bool {
        lhs.getWord() == rhs.getWord() && lhs.meta.id == rhs.meta.id && lhs.meta.uuid == rhs.meta.uuid
    }
    
    var id: String { meta.uuid }
}

struct MWMeta: Codable {
    /// The id incorporates the homograph number e.g. "hom":1; "id":"word:1";
    let id: String
    let uuid: String
    let sort: String
    let src: String
    let stems: Array<String>
    let offensive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case sort
        case src
        case stems
        case offensive
    }
    
    init(from decoder: Decoder) throws {
//        debugPrint("at MWMeta")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.sort = try container.decode(String.self, forKey: .sort)
        self.src = try container.decode(String.self, forKey: .src)
        self.stems = try container.decode([String].self, forKey: .stems)
        self.offensive = try container.decode(Bool.self, forKey: .offensive)
//        debugPrint("Finished decoding MWMeta")
    }
}

struct MWHeadwordInformation: Codable {
    let hw: String
    let prs: prs?
}

struct MWPronunciation: Codable {
    /// written pronunciation in Merriam-Webster format
    let mw: String?
    /// pronunciation label before pronunciation
    let l: String?
    /// pronunciation label after pronunciation
    let l2: String?
    /// punctuation to separate pronunciation objects
    let pun: String?
    /// audio playback information: the audio member contains the base filename for audio playback; the ref and stat members can be ignored
    let sound: MWSound?
    
    enum CodingKeys: String, CodingKey {
        case mw
        case l
        case l2
        case pun
        case sound
    }
    
    init(from decoder: Decoder) throws {
//        debugPrint("at MWPronunciation")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mw = try container.decodeIfPresent(String.self, forKey: .mw)
        self.l = try container.decodeIfPresent(String.self, forKey: .l)
        self.l2 = try container.decodeIfPresent(String.self, forKey: .l2)
        self.pun = try container.decodeIfPresent(String.self, forKey: .pun)
        self.sound = try container.decodeIfPresent(MWSound.self, forKey: .sound)
//        debugPrint("Finished decoding MWPronunciation")
    }
}

struct MWSound: Codable {
    /// Audio reference URL `https://media.merriam-webster.com/audio/prons/[language_code]/[country_code]/[format]/[subdirectory]/[base filename].[format]`
    
    let audio: String?
    let ref: String?
    let stat: String?
}

struct MWVariant: Codable {
    /// variant
    let va: String
    /// variant label, such as “or”
    let vl: String?
    let prs: prs?
}

struct MWInflections: Codable {
    /// inflection: a fully spelled-out inflection
    let `if`: String?
    /// inflection cutback: an inflection ending (eg, "-ing")
    let ifc: String?
    /// inflection label, such as “also”, “plural”, “or”
    let il: String?
    let prs: prs?
    let spl: String?
}

struct MWCognateCrossReferences: Codable {
    let cxl: String?
}

struct MWDefinition: Codable {
    let vd: String?
    let sseq: sseq?
    let sls: sls?
}

struct MWSenseSequence: Codable {
    /// Array of multiple senses/sen
    var senses: [Element]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        var decodedSenses = [Element]()
        
        while !container.isAtEnd {
            if let obj = try? container.decode(Element.self) {
                decodedSenses.append(obj)
            } else {
                try container.skip()
            }
        }

        self.senses = decodedSenses
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(senses)
    }
    
    enum Element: Codable {
        case sense(Sense)
        case pseq(MWSenseSequence)
        case sen(Sen)
        case bs(Sense)
        
        init(from decoder: Decoder) throws {
//            debugPrint("at Element of Sense")
            var container = try decoder.unkeyedContainer()
            
            let key = try container.decode(String.self)
            
            if key == "sense" {
                self = .sense(try container.decode(Sense.self))
            } else if key == "pseq" {
                self = .pseq(try container.decode(MWSenseSequence.self))
            } else if key == "sen" {
                self = .sen(try container.decode(Sen.self))
            } else if key == "bs" {
                self = .bs(try container.decode(Sense.self))
            } else {
                throw DecodingError.typeMismatch(Element.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not Sense"))
            }
//            debugPrint("Finished decoding Element of Sense")
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            
            switch self {
            case .sense(let obj):
                try container.encode("sense")
                try container.encode(obj)
            case .pseq(let obj):
                try container.encode("pseq")
                try container.encode(obj)
            case .sen(let obj):
                try container.encode("sen")
                try container.encode(obj)
            case .bs(let obj):
                try container.encode("bs")
                try container.encode(obj)
            }
        }
        
        struct Sense: Codable {
            let dt: DefiningText
            let et: MWEtymology?
            let ins: MWInflections?
            let lbs: lbs?
            let prs: prs?
            let sdsense: SDSense?
            let sgram: SenseSpecificGrammaticalLabel?
            let sls: sls?
            let sn: String?
            let vrs: vrs?
        }
        
        struct Sen: Codable {
            let et: MWEtymology?
            let ins: MWInflections?
            let lbs: lbs?
            let prs: prs?
            let sgram: SenseSpecificGrammaticalLabel?
            let sls: sls?
            let sn: String?
            let vrs: vrs?
        }
    }
    
    struct SDSense: Codable {
        /// sense divider
        let sd: String
        let dt: DefiningText
    }
    
     struct SenseSpecificGrammaticalLabel: Codable {
        let sgram: String
    }
    
    struct DefiningText: Codable {
        var text: String
        var uns: UsageNotes?
        var vis: VerbalIllustration?
        var ca: CalledAlsoNote?
        var snote: SupplementalInformationNote?
        
        init(from decoder: Decoder) throws {
//            debugPrint("at MWSenseSequence")
            
            self.text = "text"
            self.uns = nil
            self.vis = nil
            self.ca = nil
            self.snote = nil
            
            var container = try decoder.unkeyedContainer()
            
            while !container.isAtEnd {
                if let subDecoder = try? container.superDecoder() {
                    var subContainer = try subDecoder.unkeyedContainer()
                    let key = try subContainer.decode(String.self)
                    if key == "text" {
                        text = try subContainer.decode(String.self)
                    } else if key == "uns" {
                        uns = try subContainer.decode(UsageNotes.self)
                    } else if key == "vis" {
                        vis = try subContainer.decode(VerbalIllustration.self)
                    } else if key == "ca" {
                        ca = try subContainer.decode(CalledAlsoNote.self)
                    } else if key == "snote" {
                        snote = try subContainer.decode(SupplementalInformationNote.self)
                    } else {
                        try container.skip()
                    }
                } else {
                    try container.skip()
                }
            }
            
//            debugPrint("finished decoding MWSenseSequence")
        }
        
        enum CodingKeys: String, CodingKey {
            case text, uns, vis, ca
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: MWSenseSequence.DefiningText.CodingKeys.self)
            try container.encode(self.text, forKey: MWSenseSequence.DefiningText.CodingKeys.text)
            try container.encodeIfPresent(self.uns, forKey: MWSenseSequence.DefiningText.CodingKeys.uns)
            try container.encodeIfPresent(self.vis, forKey: MWSenseSequence.DefiningText.CodingKeys.vis)
            try container.encodeIfPresent(self.ca, forKey: MWSenseSequence.DefiningText.CodingKeys.ca)
        }
        
        struct VerbalIllustration: Codable {
            let content: [Element]
            
            struct Element: Codable {
                let t: String
            }
            
            init(from decoder: Decoder) throws {
//                debugPrint("at VerbalIllustration of Element of DefiningText")
                var elements = [Element]()
                var container = try decoder.unkeyedContainer()
                while !container.isAtEnd {
                    if let element = try? container.decode(Element.self) {
                        elements.append(element)
                    } else {
                        try container.skip()
                    }
                }
                content = elements
//                debugPrint("Finished decoding VerbalIllustration of Element of DefiningText")
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                try container.encode(content)
            }
        }
        
        struct CalledAlsoNote: Codable {
            let intro: String
            let cats: [Element]
            
            struct Element: Codable {
                let cat: String?
                let catref: String?
                let pn: String?
                let prs: prs?
                let psl: psl?
            }
        }
        
        struct SupplementalInformationNote: Codable {
            var notes: [Note]
            
            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                
                var notes = [Note]()
                while !container.isAtEnd {
                    if let note = try? container.decode(Note.self) {
                        notes.append(note)
                    } else {
                        try container.skip()
                    }
                }
                
                self.notes = notes
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                try container.encode(notes)
            }
            
            enum Note: Codable {
                case t(String)
                case vis(VerbalIllustration)
                
                init(from decoder: Decoder) throws {
//                    debugPrint("at Note of SupplementalInformationNote")
                    var container = try decoder.unkeyedContainer()
                    
                    let key = try container.decode(String.self)
                    if key == "t" {
                        self = .t(try container.decode(String.self))
                    } else if key == "vis" {
                        self = .vis(try container.decode(VerbalIllustration.self))
                    } else {
                        throw DecodingError.typeMismatch(SupplementalInformationNote.Note.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not element of CalledAlsoNote"))
                    }
//                    debugPrint("Finished decoding Note of SupplementalInformationNote")
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()
                    
                    switch self {
                    case .t(let obj):
                        try container.encode("t")
                        try container.encode(obj)
                    case .vis(let obj):
                        try container.encode("vis")
                        try container.encode(obj)
                    }
                }
            }
        }
        
        struct UsageNotes: Codable {
            let notes: [Note]
            
            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                
                var decodedNotes = [Note]()
                
                while !container.isAtEnd {
                    if let obj = try? container.decode(Note.self) {
                        decodedNotes.append(obj)
                    } else {
                        try container.skip()
                    }
                }

                self.notes = decodedNotes
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                try container.encode(notes)
            }
            
            struct Note: Codable {
                let values: [Element]
                
                init(from decoder: Decoder) throws {
                    var container = try decoder.unkeyedContainer()
                    
                    var decodedValues = [Element]()
                    
                    while !container.isAtEnd {
                        if let obj = try? container.decode(Element.self) {
                            decodedValues.append(obj)
                        } else {
                            try container.skip()
                        }
                    }

                    self.values = decodedValues
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()
                    try container.encode(values)
                }
                
                enum Element: Codable {
                    case textValue(String)
                    
                    init(from decoder: Decoder) throws {
//                        debugPrint("at Element of Note of UsageNotes")
                        var container = try decoder.unkeyedContainer()
                        
                        let key = try container.decode(String.self)
                        if key == "text" {
                            self = .textValue(try container.decode(String.self))
                        } else {
                            throw DecodingError.typeMismatch(UsageNotes.Note.Element.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not element of UsageNotes"))
                        }
//                        debugPrint("Finished decoding Element of Note of UsageNotes")
                    }
                    
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.unkeyedContainer()
                        
                        switch self {
                        case .textValue(let obj):
                            try container.encode("text")
                            try container.encode(obj)
                        }
                    }
                }
            }
        }
    }
}

struct MWArtwork: Codable {
    let artid: String
    let capt: String
    /// 1. If you want to link to a separate page containing both image and caption, the URL should be in the following form: https://www.merriam-webster.com/art/dict/[base filename].htm where [base filename] equals the value of artid. For the Example below, this URL would be: https://www.merriam-webster.com/art/dict/heart.htm
    
    ///2. If you prefer to link directly to the image, the URL should be in the following form: https://www.merriam-webster.com/assets/mw/static/art/dict/[base filename].gif where [base filename] equals the value of artid. Use the content of capt to pull in the caption content. For the Example below, this URL would be: https://www.merriam-webster.com/assets/mw/static/art/dict/heart.gif
}

/// Array of array
struct MWEtymology: Codable {
    let content: [Element]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        var decodedContent = [Element]()
        
        while !container.isAtEnd {
            if let obj = try? container.decode(Element.self) {
                decodedContent.append(obj)
            } else {
                try container.skip()
            }
        }

        self.content = decodedContent
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(content)
    }
    
    enum Element: Codable {
        case text(String)
        
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            
            let key = try container.decode(String.self)
            if key == "text" {
                self = .text(try container.decode(String.self))
            } else {
                throw DecodingError.typeMismatch(MWEtymology.Element.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not element of Etymology"))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            switch self {
            case .text(let obj):
                try container.encode("text")
                try container.encode(obj)
            }
        }
    }
}

struct MWSubjectStatusLabels: Codable {
    let label: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        label = try container.decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(label)
    }
}

// MARK: - Typealiases
typealias prs = Array<MWPronunciation>
/// parenthesized subject/status label
typealias psl = String

typealias sls = Array<MWSubjectStatusLabels>

typealias vrs = Array<MWVariant>

typealias ins = Array<MWInflections>

typealias cxs = Array<MWCognateCrossReferences>

typealias def = Array<MWDefinition>

typealias sseq = Array<MWSenseSequence>

typealias lbs = Array<String>

typealias shortdef = Array<String>

struct Empty: Decodable { }
extension UnkeyedDecodingContainer {
    public mutating func skip() throws {
        _ = try decode(Empty.self)
    }
}
