//
//  MWEntry.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/2/23.
//

import Foundation

struct MWRetrieveEntry: DictionaryRetrieveEntry {
    let meta: MWMeta
    let hom: Int?
    let hwi: MWHeadwordInformation?
    /// Functional label e.g. "noun", "adjective"
    let fl: String?
    let ins: ins?
    let cxs: cxs?
    let def: def?
    /// General labels e.g. typically capitalized, used as an attributive noun
    let lbs: lbs?
    let shortdef: shortdef?
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
        debugPrint("at MWMeta")
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        self.sort = try container.decode(String.self, forKey: .sort)
        self.src = try container.decode(String.self, forKey: .src)
        self.stems = try container.decode([String].self, forKey: .stems)
        self.offensive = try container.decode(Bool.self, forKey: .offensive)
        debugPrint("Finished decoding MWMeta")
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mw = try container.decodeIfPresent(String.self, forKey: .mw)
        self.l = try container.decodeIfPresent(String.self, forKey: .l)
        self.l2 = try container.decodeIfPresent(String.self, forKey: .l2)
        self.pun = try container.decodeIfPresent(String.self, forKey: .pun)
        self.sound = try container.decodeIfPresent(MWSound.self, forKey: .sound)
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
    let va: String?
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
    let sseq: Array<MWSenseSequence>?
    let sls: sls?
}

struct MWSenseSequence: Codable {
    var senses: Array<MWSense>
    
    init(from decoder: Decoder) throws {
        debugPrint("at MWSenseSequence")
        var container = try decoder.unkeyedContainer()
        var senses = Array<MWSense>()
        
        while !container.isAtEnd {
            if let obj = try? container.decode(MWSense.self) {
                senses.append(obj)
            } else {
                try container.skip()
            }
        }
        
        self.senses = senses
        debugPrint("finished decoding MWSenseSequence")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(senses)
    }
}

/// Array of multiple senses/sen
struct MWSense: Codable {
    let sense: Element
    
    enum Element: Codable {
        case senses(SenseContainer)
        case sense(Sense)
        case pseq(SenseContainer)
        
        struct SenseContainer: Codable {
            let senses: [Element]
            
            enum Element: Codable {
                case sense(Sense)
                case sen(Sen)
                case bs(Sense)
                
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
                
                init(from decoder: Decoder) throws {
                    debugPrint("at Element of SenseContainer")
                    var container = try decoder.unkeyedContainer()
                    
                    let key = try container.decode(String.self)
                    
                    if key == "sense" {
                        self = .sense(try container.decode(Sense.self))
                    } else if key == "sen" {
                        self = .sen(try container.decode(Sen.self))
                    } else if key == "bs" {
                        self = .bs(try container.decode(Sense.self))
                    } else {
                        throw DecodingError.typeMismatch(MWSense.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not element of MWSense"))
                    }
                    debugPrint("finished decoding Element of SenseContainer")
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()
                    switch self {
                    case .sense(let obj):
                        try container.encode("sense")
                        try container.encode(obj)
                    case .sen(let obj):
                        try container.encode("sen")
                        try container.encode(obj)
                    case .bs(let obj):
                        try container.encode("bs")
                        try container.encode(obj)
                    }
                }
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
        
        
        init(from decoder: Decoder) throws {
            debugPrint("at Element of MWSense")
            var container = try decoder.unkeyedContainer()
            
            if let obj = try? container.decode(SenseContainer.self) {
                self = .senses(obj)
            } else if let obj = try? container.decode(Sense.self) {
                self = .sense(obj)
            } else if let key = try? container.decode(String.self), key == "pseq" {
                self = .pseq(try container.decode(SenseContainer.self))
            } else {
                throw DecodingError.typeMismatch(MWSense.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not MWSense"))
            }
            debugPrint("Finished decoding Element of MWSense")
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            
            switch self {
            case .senses(let obj):
                try container.encode(obj)
            case .sense(let obj):
                try container.encode(obj)
            case .pseq(let obj):
                try container.encode("pseq")
                try container.encode(obj)
            }
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
        let content: [Element]
        
        enum Element: Codable {
            case dt(TextValue)
            case uns(UsageNotes)
            case vis(VerbalIllustration)
            case ca(CalledAlsoNote)
            
            struct TextValue: Codable {
                let text: String
                
                init(from decoder: Decoder) throws {
                    debugPrint("at TextValue of Element of DefiningText")
                    var container = try decoder.unkeyedContainer()
                    
                    let key = try container.decode(String.self)
                    if key == "text" {
                        text = try container.decode(String.self)
                    } else {
                        throw DecodingError.typeMismatch(TextValue.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not DefiningText"))
                    }
                    debugPrint("Finished decoding TextValue of Element of DefiningText")
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()
                    let arrayValue = ["text", text]
                    try container.encode(arrayValue)
                }
            }
            
            struct VerbalIllustration: Codable {
                let content: [Element]
                
                struct Element: Codable {
                    let t: String
                    let aq: AttributionOfQuote?
                }
                
                struct AttributionOfQuote: Codable {
                    let auth, source, aqdate: String
                }
                
                init(from decoder: Decoder) throws {
                    debugPrint("at VerbalIllustration of Element of DefiningText")
                    var container = try decoder.unkeyedContainer()
                    
                    let key = try container.decode(String.self)
                    if key == "vis" {
                        content = try container.decode([Element].self)
                    } else {
                        throw DecodingError.typeMismatch(VerbalIllustration.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not VerbalIllustration"))
                    }
                    debugPrint("Finished decoding VerbalIllustration of Element of DefiningText")
                }
            }
            
            struct CalledAlsoNote: Codable {
                let notes: Notes
                
                struct Notes: Codable {
                    let intro: String
                    let cats: [Element]
                    
                    enum Element: Codable {
                        case cat(String)
                        case catref(String)
                        case pn(String)
                        case prs(prs)
                        case psl(psl)
                    }
                }
                
                init(from decoder: Decoder) throws {
                    debugPrint("at CalledAlsoNote of Element of DefiningText")
                    var container = try decoder.unkeyedContainer()
                    
                    let key = try container.decode(String.self)
                    if key == "ca" {
                        notes = try container.decode(Notes.self)
                    } else {
                        throw DecodingError.typeMismatch(CalledAlsoNote.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not CalledAlsoNote"))
                    }
                    debugPrint("Finished decoding CalledAlsoNote of Element of DefiningText")
                }
            }
            
            struct SupplementalInformationNote: Codable {
                let notes: [Note]
                
                enum Note: Codable {
                    case t(String)
                    case vis(VerbalIllustration)
                    
                    init(from decoder: Decoder) throws {
                        debugPrint("at Note of SupplementalInformationNote")
                        var container = try decoder.unkeyedContainer()
                        
                        let key = try container.decode(String.self)
                        if key == "t" {
                            self = .t(try container.decode(String.self))
                        } else if key == "vis" {
                            self = .vis(try container.decode(VerbalIllustration.self))
                        } else {
                            throw DecodingError.typeMismatch(SupplementalInformationNote.Note.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not element of CalledAlsoNote"))
                        }
                        debugPrint("Finished decoding Note of SupplementalInformationNote")
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
                
                init(from decoder: Decoder) throws {
                    debugPrint("at SupplementalInformationNote")
                    var container = try decoder.unkeyedContainer()
                    
                    let key = try container.decode(String.self)
                    if key == "snote" {
                        notes = try container.decode([Note].self)
                    } else {
                        throw DecodingError.typeMismatch(SupplementalInformationNote.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not SupplementalInformationNote"))
                    }
                    debugPrint("Finished decoding SupplementalInformationNote")
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()
                    try container.encode("snote")
                    try container.encode(notes)
                }
            }
            
            struct UsageNotes: Codable {
                let notes: [Note]
                
                struct Note: Codable {
                    let values: [Element]
                    
                    enum Element: Codable {
                        case textValue(String)
                        
                        init(from decoder: Decoder) throws {
                            debugPrint("at Element of Note of UsageNotes")
                            var container = try decoder.unkeyedContainer()
                            
                            let key = try container.decode(String.self)
                            if key == "text" {
                                self = .textValue(try container.decode(String.self))
                            } else {
                                throw DecodingError.typeMismatch(UsageNotes.Note.Element.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not element of UsageNotes"))
                            }
                            debugPrint("Finished decoding Element of Note of UsageNotes")
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
                
                init(from decoder: Decoder) throws {
                    debugPrint("at UsageNotes")
                    var container = try decoder.unkeyedContainer()
                    
                    let key = try container.decode(String.self)
                    if key == "uns" {
                        notes = try container.decode([Note].self)
                    } else {
                        throw DecodingError.typeMismatch(UsageNotes.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not UsageNotes"))
                    }
                    debugPrint("Finished decoding UsageNotes")
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()
                    
                    try container.encode("uns")
                    try container.encode(notes)
                }
            }
            
            init(from decoder: Decoder) throws {
                debugPrint("at Element of DefiningText")
                var container = try decoder.unkeyedContainer()
                
                if let obj = try? container.decode(TextValue.self) {
                    self = .dt(obj)
                } else if let obj = try? container.decode(UsageNotes.self) {
                    self = .uns(obj)
                } else if let obj = try? container.decode(VerbalIllustration.self) {
                    self = .vis(obj)
                } else {
                    throw DecodingError.typeMismatch(DefiningText.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not element of DefiningText"))
                }
                debugPrint("Finished decoding Element of DefiningText")
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                
                switch self {
                case .dt(let obj):
                    try container.encode(obj)
                case .uns(let obj):
                    try container.encode(obj)
                case .vis(let obj):
                    try container.encode(obj)
                case .ca(let obj):
                    try container.encode(obj)
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
    
    enum Element: Codable {
        case text(EtymologyText)
        
        struct EtymologyText: Codable {
            let text: String
            
            init(from decoder: Decoder) throws {
                debugPrint("at EtymologyText")
                var container = try decoder.unkeyedContainer()
                
                let key = try container.decode(String.self)
                if key == "text" {
                    text = try container.decode(String.self)
                } else {
                    throw DecodingError.typeMismatch(EtymologyText.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Type not Etymology"))
                }
                debugPrint("Finished decoding EtymologyText")
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                try container.encode("text")
                try container.encode(text)
            }
        }
    }
}

struct MWSubjectStatusLabels: Codable {
    let label: String?
    
    init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()
        label = try container.decode(String.self)
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

typealias lbs = Array<String>

typealias shortdef = Array<String>

struct Empty: Decodable { }
extension UnkeyedDecodingContainer {
    public mutating func skip() throws {
        _ = try decode(Empty.self)
    }
}
