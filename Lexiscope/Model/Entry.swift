//
//  Entry.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/11/22.
//

import Foundation

/// Model transcribed from *Oxford Dictionary* https://developer.oxforddictionaries.com/documentation
    
// MARK: - Typealiases
typealias PronunciationsList = Array<InlineModel1>
typealias ArrayOfRelatedEntries = Array<InlineModel2>

typealias GrammaticalFeaturesList = Array<InlineModel3>

typealias CategorizedTextList = Array<InlineModel4>
typealias VariantFormsList = Array<InlineModel5>

typealias CrossReferencesList = Array<InlineModel6>

typealias regionsList = Array<InlineModel7>
typealias registersList = Array<InlineModel8>
typealias domainsList = Array<InlineModel9>

typealias SynonymsAntonyms = InlineModel10

typealias domainClassesList = Array<InlineModel11>
typealias ExamplesList = Array<InlineModel12>
typealias semanticClassesList = Array<InlineModel13>

typealias ExampleText = String

// MARK: - Model Types
class RetrieveEntry: Codable {
    var metadata: Dictionary<String, String>?
    var results: Array<HeadwordEntry>?
}

public class HeadwordEntry: NSObject, Codable, NSSecureCoding, Identifiable {
    
    public var id: String
    var language: String
    var lexicalEntries: Array<LexicalEntry>
    var pronunciations: PronunciationsList?
    var type: String?
    var word: String
    
    public static var supportsSecureCoding: Bool = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: HeadwordEntry.Keys.id.rawValue)
        coder.encode(language, forKey: HeadwordEntry.Keys.language.rawValue)
        coder.encode(lexicalEntries, forKey: HeadwordEntry.Keys.lexicalEntries.rawValue)
        coder.encode(pronunciations, forKey: HeadwordEntry.Keys.pronunciations.rawValue)
        coder.encode(type, forKey: HeadwordEntry.Keys.type.rawValue)
        coder.encode(word, forKey: HeadwordEntry.Keys.word.rawValue)
    }
    
    public required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: HeadwordEntry.Keys.id.rawValue) as? String,
              let language = coder.decodeObject(of: NSString.self, forKey: HeadwordEntry.Keys.language.rawValue) as? String,
              let lexicalEntries = coder.decodeObject(of: [LexicalEntry.self], forKey: HeadwordEntry.Keys.lexicalEntries.rawValue) as? Array<LexicalEntry>,
              let pronunciations = coder.decodeObject(of: [InlineModel1.self], forKey: HeadwordEntry.Keys.pronunciations.rawValue) as? PronunciationsList?,
              let type = coder.decodeObject(of: NSString.self, forKey: HeadwordEntry.Keys.type.rawValue) as String?,
              let word = coder.decodeObject(of: NSString.self, forKey: HeadwordEntry.Keys.word.rawValue) as? String else {
            fatalError("Issue decoding HeadwordEntry")
        }
        
        self.id = id
        self.language = language
        self.lexicalEntries = lexicalEntries
        self.pronunciations = pronunciations
        self.type = type
        self.word = word
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case id = "id"
        case language = "language"
        case lexicalEntries = "lexicalEntries"
        case pronunciations = "pronunciations"
        case type = "type"
        case word = "word"
    }
}

class LexicalEntry: NSObject, Codable, NSSecureCoding, Identifiable {
    
    var id: String {
        return lexicalCategory.id
    }
    var entries: Array<Entry>
    var language: String
    var lexicalCategory: LexicalCategory
    var pronunciations: PronunciationsList?
    var root: String?
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(entries, forKey: LexicalEntry.Keys.entries.rawValue)
        coder.encode(language, forKey: LexicalEntry.Keys.language.rawValue)
        coder.encode(lexicalCategory, forKey: LexicalEntry.Keys.lexicalCategory.rawValue)
        coder.encode(pronunciations, forKey: LexicalEntry.Keys.pronunciations.rawValue)
        coder.encode(root, forKey: LexicalEntry.Keys.root.rawValue)
        coder.encode(text, forKey: LexicalEntry.Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let entries = coder.decodeObject(of: [Entry.self], forKey: LexicalEntry.Keys.entries.rawValue) as? Array<Entry>,
              let language = coder.decodeObject(of: NSString.self, forKey: LexicalEntry.Keys.language.rawValue) as? String,
              let lexicalCategory = coder.decodeObject(of: LexicalCategory.self, forKey: LexicalEntry.Keys.lexicalCategory.rawValue),
              let pronunciations = coder.decodeObject(of: [InlineModel1.self], forKey: LexicalEntry.Keys.pronunciations.rawValue) as? PronunciationsList?,
              let root = coder.decodeObject(of: NSString.self, forKey: LexicalEntry.Keys.root.rawValue) as String?,
              let text = coder.decodeObject(of: NSString.self, forKey: LexicalEntry.Keys.text.rawValue) as? String else {
            fatalError("Issue decoding LexicalEntry")
        }
        
        self.entries = entries
        self.language = language
        self.lexicalCategory = lexicalCategory
        self.pronunciations = pronunciations
        self.root = root
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case id = "id"
        case entries = "entries"
        case language = "language"
        case lexicalCategory = "lexicalCategory"
        case pronunciations = "pronunciations"
        case root = "root"
        case text = "text"
    }
}

class Entry: NSObject, Codable, NSSecureCoding, Identifiable {
    /// A grouping of crossreference notes.
    var crossReferenceMarkers: Array<String>?
    var crossReferences: CrossReferencesList?
    /// The origin of the word and the way in which its meaning has changed throughout history.
    var etymologies: Array<String>?
    var grammaticalFeatures: GrammaticalFeaturesList?
    /// Identifies the homograph grouping. The last two digits identify different entries of the same homograph. The first one/two digits identify the homograph number.
    var homographNumber: String?
    /// A list of inflected forms for an Entry.
    var inflections: Array<InflectedForm>?
    var notes: CategorizedTextList?
    var pronunciations: PronunciationsList?
    var senses: Array<Sense>?
    /// Various words that are used interchangeably depending on the context, e.g 'a' and 'an'.
    var variantForms: VariantFormsList?

    var id: String {
        return homographNumber ?? UUID().uuidString
    }
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(crossReferenceMarkers, forKey: Keys.crossReferenceMarkers.rawValue)
        coder.encode(crossReferences, forKey: Keys.crossReferences.rawValue)
        coder.encode(etymologies, forKey: Keys.etymologies.rawValue)
        coder.encode(grammaticalFeatures, forKey: Keys.grammaticalFeatures.rawValue)
        coder.encode(homographNumber, forKey: Keys.homographNumber.rawValue)
        coder.encode(inflections, forKey: Keys.inflections.rawValue)
        coder.encode(notes, forKey: Keys.notes.rawValue)
        coder.encode(pronunciations, forKey: Keys.pronunciations.rawValue)
        coder.encode(senses, forKey: Keys.senses.rawValue)
        coder.encode(variantForms, forKey: Keys.variantForms.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let crossReferenceMarkers = coder.decodeObject(of: [NSString.self], forKey: Keys.crossReferenceMarkers.rawValue) as? Array<String>?,
              let crossReferences = coder.decodeObject(of: [InlineModel6.self], forKey: Keys.crossReferences.rawValue) as? CrossReferencesList?,
              let etymologies = coder.decodeObject(of: [NSString.self], forKey: Keys.etymologies.rawValue) as? Array<String>?,
              let grammaticalFeatures = coder.decodeObject(of: [InlineModel3.self], forKey: Keys.grammaticalFeatures.rawValue) as? GrammaticalFeaturesList?,
              let homographNumber = coder.decodeObject(of: NSString.self, forKey: Keys.homographNumber.rawValue) as String?,
              let inflections = coder.decodeObject(of: [InflectedForm.self], forKey: Keys.inflections.rawValue) as? Array<InflectedForm>?,
              let notes = coder.decodeObject(of: [InlineModel4.self], forKey: Keys.notes.rawValue) as? CategorizedTextList?,
              let pronunciations = coder.decodeObject(of: [InlineModel1.self], forKey: Keys.pronunciations.rawValue) as? PronunciationsList?,
              let senses = coder.decodeObject(of: [Sense.self], forKey: Keys.senses.rawValue) as? Array<Sense>?,
              let variantForms = coder.decodeObject(of: [InlineModel5.self], forKey: Keys.variantForms.rawValue) as? VariantFormsList? else {
            fatalError("Issue decoding Entry")
        }
        
        self.crossReferenceMarkers = crossReferenceMarkers
        self.crossReferences = crossReferences
        self.etymologies = etymologies
        self.grammaticalFeatures = grammaticalFeatures
        self.homographNumber = homographNumber
        self.inflections = inflections
        self.notes = notes
        self.pronunciations = pronunciations
        self.senses = senses
        self.variantForms = variantForms
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case crossReferenceMarkers = "crossReferenceMarkers"
        case crossReferences = "crossReferences"
        case etymologies = "etymologies"
        case grammaticalFeatures = "grammaticalFeatures"
        case homographNumber = "homographNumber"
        case inflections = "inflections"
        case notes = "notes"
        case pronunciations = "pronunciations"
        case senses = "senses"
        case variantForms = "variantForms"
    }
}

class LexicalCategory: NSObject, Codable, NSSecureCoding {
    var id: String
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as? String,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding LexicalCategory")
        }

        self.id = id
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case id = "id"
        case text = "text"
    }
}

class InflectedForm: NSObject, Codable, NSSecureCoding {
    /// A subject, discipline, or branch of knowledge particular to the Inflection.
    var domains: domainsList?
    var grammaticalFeatures: GrammaticalFeaturesList?
    /// Canonical form of an inflection.
    var inflectedForm: String
    var lexicalCategory: LexicalCategory?
    var pronunciations: PronunciationsList?
    /// A particular area in which the Inflection occurs, e.g. 'Great Britain'.
    var regions: regionsList?
    /// A level of language usage, typically with respect to formality. e.g. 'offensive', 'informal'.
    var registers: registersList?
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(domains, forKey: Keys.domains.rawValue)
        coder.encode(grammaticalFeatures, forKey: Keys.grammaticalFeatures.rawValue)
        coder.encode(inflectedForm, forKey: Keys.inflectedForm.rawValue)
        coder.encode(lexicalCategory, forKey: Keys.lexicalCategory.rawValue)
        coder.encode(pronunciations, forKey: Keys.pronunciations.rawValue)
        coder.encode(regions, forKey: Keys.regions.rawValue)
        coder.encode(registers, forKey: Keys.registers.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let domains = coder.decodeObject(of: [InlineModel9.self], forKey: Keys.domains.rawValue) as? domainsList?,
                let grammaticalFeatures = coder.decodeObject(of: [InlineModel3.self], forKey: Keys.grammaticalFeatures.rawValue) as? GrammaticalFeaturesList?,
                let inflectionForm = coder.decodeObject(of: NSString.self, forKey: Keys.inflectedForm.rawValue) as? String,
                let lexicalCategory = coder.decodeObject(of: LexicalCategory.self, forKey: Keys.lexicalCategory.rawValue) as LexicalCategory?,
                let pronunciations = coder.decodeObject(of: [InlineModel1.self], forKey: Keys.pronunciations.rawValue) as? PronunciationsList?,
                let regions = coder.decodeObject(of: [InlineModel7.self], forKey: Keys.regions.rawValue) as? regionsList?,
                let registers = coder.decodeObject(of: [InlineModel8.self], forKey: Keys.registers.rawValue) as? registersList? else {
            fatalError("Issue decoding InflectedForm")
        }
        
        self.domains = domains
        self.grammaticalFeatures = grammaticalFeatures
        self.inflectedForm = inflectionForm
        self.lexicalCategory = lexicalCategory
        self.pronunciations = pronunciations
        self.regions = regions
        self.registers = registers
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case domains = "domains"
        case grammaticalFeatures = "grammaticalFeatures"
        case inflectedForm = "inflectedForm"
        case lexicalCategory = "lexicalCategory"
        case pronunciations = "pronunciations"
        case regions = "regions"
        case registers = "registers"
    }
}

class Sense: NSObject, Codable, NSSecureCoding {
    /// An antonym of a word.
    var antonyms: SynonymsAntonyms?
    /// A construction provides information about typical syntax used of this sense. Each construction may optionally have one or more examples.
    var constructions: Array<inline_model_2>?
    /// A grouping of crossreference notes.
    var crossReferenceMarkers: Array<String>?
    var crossReferences: CrossReferencesList?
    /// A list of statements of the exact meaning of a word.
    var definitions: Array<String>?
    /// Domain classes particular to the Sense.
    var domainClasses: domainClassesList?
    /// A subject, discipline, or branch of knowledge particular to the Sense.
    var domains: domainsList?
    /// The origin of the word and the way in which its meaning has changed throughout history.
    var etymologies: Array<String>?
    var examples: ExamplesList?
    ///  The id of the sense that is required for the delete procedure.
    var id: String?
    ///  A list of inflected forms for a sense.
    var inflections: Array<InflectedForm>?
    var notes: CategorizedTextList?
    var pronunciations: PronunciationsList?
    /// A particular area in which the Sense occurs, e.g. 'Great Britain'.
    var regions: regionsList?
    /// A level of language usage, typically with respect to formality. e.g. 'offensive', 'informal'.
    var registers: registersList?
    /// Semantic classes particular to the Sense.
    var semanticClasses: semanticClassesList?
    /// A list of short statements of the exact meaning of a word.
    var shortDefinitions: Array<String>?
    /// Ordered list of subsenses of a sense.
    var subsenses: Array<Sense>?
    /// synonym of word.
    var synonyms: SynonymsAntonyms?
    /// Ordered list of links to the Thesaurus Dictionary.
    var thesaurusLinks: Array<thesaurusLink>?
    /// Various words that are used interchangeably depending on the context, e.g 'duck' and 'duck boat'.
    var variantForms: VariantFormsList?
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(antonyms, forKey: Keys.antonyms.rawValue)
        coder.encode(constructions, forKey: Keys.constructions.rawValue)
        coder.encode(crossReferenceMarkers, forKey: Keys.crossReferenceMarkers.rawValue)
        coder.encode(crossReferences, forKey: Keys.crossReferences.rawValue)
        coder.encode(definitions, forKey: Keys.definitions.rawValue)
        coder.encode(domainClasses, forKey: Keys.domainClasses.rawValue)
        coder.encode(domains, forKey: Keys.domains.rawValue)
        coder.encode(etymologies, forKey: Keys.etymologies.rawValue)
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(inflections, forKey: Keys.inflections.rawValue)
        coder.encode(notes, forKey: Keys.notes.rawValue)
        coder.encode(pronunciations, forKey: Keys.pronunciations.rawValue)
        coder.encode(regions, forKey: Keys.regions.rawValue)
        coder.encode(registers, forKey: Keys.registers.rawValue)
        coder.encode(semanticClasses, forKey: Keys.semanticClasses.rawValue)
        coder.encode(shortDefinitions, forKey: Keys.shortDefinitions.rawValue)
        coder.encode(subsenses, forKey: Keys.subsenses.rawValue)
        coder.encode(synonyms, forKey: Keys.synonyms.rawValue)
        coder.encode(thesaurusLinks, forKey: Keys.thesaurusLinks.rawValue)
        coder.encode(variantForms, forKey: Keys.variantForms.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let antonyms = coder.decodeObject(of: InlineModel10.self, forKey: Keys.antonyms.rawValue) as SynonymsAntonyms?,
              let constructions = coder.decodeObject(of: [inline_model_2.self], forKey: Keys.constructions.rawValue) as? Array<inline_model_2>?,
              let crossReferenceMarkers = coder.decodeObject(of: [NSString.self], forKey: Keys.crossReferenceMarkers.rawValue) as? Array<String>?,
              let crossReferences = coder.decodeObject(of: [InlineModel6.self], forKey: Keys.crossReferences.rawValue) as? CrossReferencesList?,
              let definitions = coder.decodeObject(of: [NSString.self], forKey: Keys.definitions.rawValue) as? Array<String>?,
              let domainClasses = coder.decodeObject(of: [InlineModel11.self], forKey: Keys.domainClasses.rawValue) as? domainClassesList?,
              let domains = coder.decodeObject(of: [InlineModel9.self], forKey: Keys.domains.rawValue) as? domainsList?,
              let etymologies = coder.decodeObject(of: [NSString.self], forKey: Keys.etymologies.rawValue) as? Array<String>?,
              let examples = coder.decodeObject(of: [InlineModel12.self], forKey: Keys.examples.rawValue) as? ExamplesList?,
              let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as String?,
              let inflections = coder.decodeObject(of: [InflectedForm.self], forKey: Keys.inflections.rawValue) as? Array<InflectedForm>?,
              let notes = coder.decodeObject(of: [InlineModel4.self], forKey: Keys.notes.rawValue) as? CategorizedTextList?,
              let pronunciations = coder.decodeObject(of: [InlineModel1.self], forKey: Keys.pronunciations.rawValue) as? PronunciationsList?,
              let regions = coder.decodeObject(of: [InlineModel7.self], forKey: Keys.regions.rawValue) as? regionsList?,
              let registers = coder.decodeObject(of: [InlineModel8.self], forKey: Keys.registers.rawValue) as? registersList?,
              let semanticClasses = coder.decodeObject(of: [InlineModel13.self], forKey: Keys.semanticClasses.rawValue) as? semanticClassesList?,
              let shortDefinitions = coder.decodeObject(of: [NSString.self], forKey: Keys.shortDefinitions.rawValue) as? Array<String>?,
              let subsenses = coder.decodeObject(of: [Sense.self], forKey: Keys.subsenses.rawValue) as? Array<Sense>?,
              let synonyms = coder.decodeObject(of: InlineModel10.self, forKey: Keys.synonyms.rawValue) as SynonymsAntonyms?,
              let thesaurusLinks = coder.decodeObject(of: [thesaurusLink.self], forKey: Keys.thesaurusLinks.rawValue) as? Array<thesaurusLink>?,
              let variantForms = coder.decodeObject(of: [InlineModel5.self], forKey: Keys.variantForms.rawValue) as? VariantFormsList? else {
            fatalError("Issue decoding Sense")
        }
        
        self.antonyms = antonyms
        self.constructions = constructions
        self.crossReferenceMarkers = crossReferenceMarkers
        self.crossReferences = crossReferences
        self.definitions = definitions
        self.domainClasses = domainClasses
        self.domains = domains
        self.etymologies = etymologies
        self.examples = examples
        self.id = id
        self.inflections = inflections
        self.notes = notes
        self.pronunciations = pronunciations
        self.regions = regions
        self.registers = registers
        self.semanticClasses = semanticClasses
        self.shortDefinitions = shortDefinitions
        self.subsenses = subsenses
        self.synonyms = synonyms
        self.thesaurusLinks = thesaurusLinks
        self.variantForms = variantForms
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case antonyms = "antonyms"
        case constructions = "constructions"
        case crossReferenceMarkers = "crossReferenceMarkers"
        case crossReferences = "crossReferences"
        case definitions = "definitions"
        case domainClasses = "domainClasses"
        case domains = "domains"
        case etymologies = "etymologies"
        case examples = "examples"
        case id = "id"
        case inflections = "inflections"
        case notes = "notes"
        case pronunciations = "pronunciations"
        case regions = "regions"
        case registers = "registers"
        case semanticClasses = "semanticClasses"
        case shortDefinitions = "shortDefinitions"
        case subsenses = "subsenses"
        case synonyms = "synonyms"
        case thesaurusLinks = "thesaurusLinks"
        case variantForms = "variantForms"
        
    }
}

class thesaurusLink: NSObject, Codable, NSSecureCoding {
    /// identifier of a word.
    var entry_id: String
    /// identifier of a sense.
    var sense_id: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(entry_id, forKey: Keys.entry_id.rawValue)
        coder.encode(sense_id, forKey: Keys.sense_id.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let entry_id = coder.decodeObject(of: NSString.self, forKey: Keys.entry_id.rawValue) as? String,
              let sense_id = coder.decodeObject(of: NSString.self, forKey: Keys.sense_id.rawValue) as? String else {
            fatalError("Issue decoding thesaurusLink")
        }
        self.entry_id = entry_id
        self.sense_id = sense_id
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case entry_id = "entry_id"
        case sense_id = "sense_id"
    }
}

// MARK: - Inline Models

class InlineModel1: NSObject, Codable, NSSecureCoding {
    /// The URL of the sound file.
    var audioFile: String?
    /// A local or regional variation where the pronunciation occurs, e.g. 'British English'.
    var dialects: Array<String>?
    /// The alphabetic system used to display the phonetic spelling.
    var phoneticNotation: String?
    ///  Phonetic spelling is the representation of vocal sounds which express pronunciations of words. It is a system of spelling in which each letter represents invariably the same spoken sound.
    var phoneticSpelling: String?
    /// A particular area in which the pronunciation occurs, e.g. 'Great Britain'.
    var regions: regionsList?
    /// A level of language usage, typically with respect to formality. e.g. 'offensive', 'informal'.
    var registers: registersList?
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(audioFile, forKey: Keys.audioFile.rawValue)
        coder.encode(dialects, forKey: Keys.dialects.rawValue)
        coder.encode(phoneticNotation, forKey: Keys.phoneticNotion.rawValue)
        coder.encode(phoneticSpelling, forKey: Keys.phoneticSpelling.rawValue)
        coder.encode(regions, forKey: Keys.regions.rawValue)
        coder.encode(registers, forKey: Keys.registers.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let audioFile = coder.decodeObject(of: NSString.self, forKey: Keys.audioFile.rawValue) as String?,
              let dialects = coder.decodeObject(of: [NSString.self], forKey: Keys.dialects.rawValue) as? Array<String>?,
              let phoneticNotation = coder.decodeObject(of: NSString.self, forKey: Keys.phoneticNotion.rawValue) as String?,
              let phoneticSpelling = coder.decodeObject(of: NSString.self, forKey: Keys.phoneticSpelling.rawValue) as String?,
              let regions = coder.decodeObject(of: [InlineModel7.self], forKey: Keys.regions.rawValue) as? regionsList?,
              let registers = coder.decodeObject(of: [InlineModel8.self], forKey: Keys.registers.rawValue) as? registersList? else {
            fatalError("Issue decoding InlineModel1")
        }
        
        self.audioFile = audioFile
        self.dialects = dialects
        self.phoneticNotation = phoneticNotation
        self.phoneticSpelling = phoneticSpelling
        self.regions = regions
        self.registers = registers
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case audioFile = "audioFile"
        case dialects = "dialects"
        case phoneticNotion = "phoneticNotion"
        case phoneticSpelling = "phoneticSpelling"
        case regions = "regions"
        case registers = "registers"
    }
}

class InlineModel2: NSObject, Codable, NSSecureCoding {
    /// A subject, discipline, or branch of knowledge particular to the Sense.
    var domains: domainsList?
    /// The identifier of the word.
    var id: String
    /// IANA language code specifying the language of the word.
    var language: String
    /// A particular area in which the pronunciation occurs, e.g. 'Great Britain'.
    var regions: regionsList?
    /// A level of language usage, typically with respect to formality. e.g. 'offensive', 'informal'.
    var registers: registersList?
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(domains, forKey: Keys.domains.rawValue)
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(language, forKey: Keys.language.rawValue)
        coder.encode(regions, forKey: Keys.regions.rawValue)
        coder.encode(registers, forKey: Keys.registers.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let domains = coder.decodeObject(of: [InlineModel9.self], forKey: Keys.domains.rawValue) as? domainsList?,
              let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as? String,
              let language = coder.decodeObject(of: NSString.self, forKey: Keys.language.rawValue) as? String,
              let regions = coder.decodeObject(of: [InlineModel7.self], forKey: Keys.regions.rawValue) as? regionsList?,
              let registers = coder.decodeObject(of: [InlineModel8.self], forKey: Keys.registers.rawValue) as? registersList?,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding InlineModel2")
        }
        
        self.domains = domains
        self.id = id
        self.language = language
        self.regions = regions
        self.registers = registers
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case domains = "domains"
        case id = "id"
        case language = "language"
        case regions = "regions"
        case registers = "registers"
        case text = "text"
    }
}

class inline_model_2: NSObject, Codable, NSSecureCoding {
    var domains: domainsList?
    var examples: Array<ExampleText>?
    var notes: CategorizedTextList?
    var regions: regionsList?
    var registers: registersList?
    /// The construction text.
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(domains, forKey: Keys.domains.rawValue)
        coder.encode(examples, forKey: Keys.examples.rawValue)
        coder.encode(notes, forKey: Keys.notes.rawValue)
        coder.encode(regions, forKey: Keys.regions.rawValue)
        coder.encode(registers, forKey: Keys.registers.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let domains = coder.decodeObject(of: [InlineModel9.self], forKey: Keys.domains.rawValue) as? domainsList?,
              let examples = coder.decodeObject(of: [NSString.self], forKey: Keys.examples.rawValue) as? Array<ExampleText>?,
              let notes = coder.decodeObject(of: [InlineModel4.self], forKey: Keys.notes.rawValue) as? CategorizedTextList?,
              let regions = coder.decodeObject(of: [InlineModel7.self], forKey: Keys.regions.rawValue) as? regionsList?,
              let registers = coder.decodeObject(of: [InlineModel8.self], forKey: Keys.registers.rawValue) as? registersList?,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding InlineModel2")
        }
        
        self.domains = domains
        self.examples = examples
        self.notes = notes
        self.regions = regions
        self.registers = registers
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case domains = "domains"
        case examples = "examples"
        case notes = "notes"
        case regions = "regions"
        case registers = "registers"
        case text = "text"
    }
}

class InlineModel3: NSObject, Codable, NSSecureCoding {
    var id: String
    var text: String
    var type: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
        coder.encode(type, forKey: Keys.type.rawValue)
    }

    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as? String,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String,
              let type = coder.decodeObject(of: NSString.self, forKey: Keys.type.rawValue) as? String else {
            fatalError("Issue decoding InlineModel3")
        }

        self.id = id
        self.text = text
        self.type = type
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case id = "id"
        case text = "text"
        case type = "type"
    }
}

class InlineModel4: NSObject, Codable, NSSecureCoding {
    /// The identifier of the word.
    var id: String?
    /// A note text.
    var text: String
    /// The descriptive category of the text.
    var type: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
        coder.encode(type, forKey: Keys.type.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as String?,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String,
              let type = coder.decodeObject(of: NSString.self, forKey: Keys.type.rawValue) as? String else {
            fatalError("Issue decoding InlineModel4")
        }

        self.id = id
        self.text = text
        self.type = type
    }
    
    enum Keys: String {
        typealias RawValue = String

        case id = "id"
        case text = "text"
        case type = "type"
    }
}

class InlineModel5: NSObject, Codable, NSSecureCoding {
    /// A subject, discipline, or branch of knowledge particular to the Sense.
    var domains: domainsList?
    var notes: CategorizedTextList?
    /// A grouping of pronunciation information.
    var pronunciations: PronunciationsList?
    /// A particular area in which the variant form occurs, e.g. 'Great Britain'.
    var regions: regionsList?
    /// A level of language usage, typically with respect to formality. e.g. 'offensive', 'informal'.
    var registers: registersList?
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(domains, forKey: Keys.domains.rawValue)
        coder.encode(notes, forKey: Keys.notes.rawValue)
        coder.encode(pronunciations, forKey: Keys.pronunciations.rawValue)
        coder.encode(regions, forKey: Keys.regions.rawValue)
        coder.encode(registers, forKey: Keys.registers.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }

    required init?(coder: NSCoder) {
        guard let domains = coder.decodeObject(of: [InlineModel9.self], forKey: Keys.domains.rawValue) as? domainsList?,
              let notes = coder.decodeObject(of: [InlineModel4.self], forKey: Keys.notes.rawValue) as? CategorizedTextList?,
              let pronunciations = coder.decodeObject(of: [InlineModel1.self], forKey: Keys.pronunciations.rawValue) as? PronunciationsList?,
              let regions = coder.decodeObject(of: [InlineModel7.self], forKey: Keys.regions.rawValue) as? regionsList?,
              let registers = coder.decodeObject(of: [InlineModel8.self], forKey: Keys.registers.rawValue) as? registersList?,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding InlineModel5")
        }

        self.domains = domains
        self.notes = notes
        self.pronunciations = pronunciations
        self.regions = regions
        self.registers = registers
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String

        case domains = "domains"
        case notes = "notes"
        case pronunciations = "pronunciations"
        case regions = "regions"
        case registers = "registers"
        case text = "text"
    }
}

class InlineModel6: NSObject, Codable, NSSecureCoding {
    /// The word id of the co-occurrence.
    var id: String
    /// The word of the co-occurrence.
    var text: String
    /// The type of relation between the two words. Possible values are 'close match', 'related', 'see also', 'variant spelling', and 'abbreviation' in case of crossreferences, or 'pre', 'post' in case of collocates.
    var type: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
        coder.encode(type, forKey: Keys.type.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as? String,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String,
              let type = coder.decodeObject(of: NSString.self, forKey: Keys.type.rawValue) as? String else {
            fatalError("Issue decoding InlineModel6")
        }

        self.id = id
        self.text = text
        self.type = type
    }
    
    enum Keys: String {
        typealias RawValue = String

        case id = "id"
        case text = "text"
        case type = "type"
    }
}

class InlineModel7: NSObject, Codable, NSSecureCoding {
    var id: String
    var text: String
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as? String,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding InlineModel7")
        }

        self.id = id
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String

        case id = "id"
        case text = "text"
    }
}

class InlineModel8: NSObject, Codable, NSSecureCoding {
    var id: String
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as? String,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding InlineModel8")
        }

        self.id = id
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String

        case id = "id"
        case text = "text"
    }
}

class InlineModel9: NSObject, Codable, NSSecureCoding {
    var id: String
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as? String,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding InlineModel9")
        }

        self.id = id
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case id = "id"
        case text = "text"
    }
}

class InlineModel10: NSObject, Codable, NSSecureCoding {
    var domains: domainsList?
    var id: String?
    var language: String?
    ///  A particular area in which the Sense occurs, e.g. 'Great Britain'.
    var regions: regionsList?
    /// A level of language usage, typicCodable, ally with respect to formality. e.g. 'offensive', 'informal'.
    var registers: registersList?
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(domains, forKey: Keys.domains.rawValue)
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(language, forKey: Keys.language.rawValue)
        coder.encode(regions, forKey: Keys.regions.rawValue)
        coder.encode(registers, forKey: Keys.registers.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let domains = coder.decodeObject(of: [InlineModel9.self], forKey: Keys.domains.rawValue) as? domainsList?,
              let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as String?,
              let language = coder.decodeObject(of: NSString.self, forKey: Keys.language.rawValue) as String?,
              let regions = coder.decodeObject(of: [InlineModel7.self], forKey: Keys.regions.rawValue) as? regionsList?,
              let registers = coder.decodeObject(of: [InlineModel8.self], forKey: Keys.registers.rawValue) as? registersList?,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding InlineModel10")
        }

        self.domains = domains
        self.id = id
        self.language = language
        self.regions = regions
        self.registers = registers
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String

        case domains = "domains"
        case id = "id"
        case language = "language"
        case regions = "regions"
        case registers = "registers"
        case text = "text"
    }
}

class InlineModel11: NSObject, Codable, NSSecureCoding {
    var id: String
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as? String,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding InlineModel11")
        }

        self.id = id
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case id = "id"
        case text = "text"
    }
}

class InlineModel12: NSObject, Codable, NSSecureCoding {
    /// A list of statements of the exact meaning of a word.
    var definitions: Array<String>
    /// A subject, discipline, or branch of knowledge particular to the Sense.
    var domains: domainsList?
    var notes: CategorizedTextList?
    /// A particular area in which the pronunciation occurs, e.g. 'Great Britain'.
    var regions: regionsList?
    /// A level of language usage, typically with respect to formality. e.g. 'offensive', 'informal'.
    var registers: registersList?
    /// The list of sense identifiers related to the example. Provided in the sentences endpoint only.
    var senseIds: Array<String>
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(definitions, forKey: Keys.definitions.rawValue)
        coder.encode(domains, forKey: Keys.domains.rawValue)
        coder.encode(notes, forKey: Keys.notes.rawValue)
        coder.encode(regions, forKey: Keys.regions.rawValue)
        coder.encode(registers, forKey: Keys.registers.rawValue)
        coder.encode(senseIds, forKey: Keys.senseIds.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let definitions = coder.decodeObject(of: [NSString.self], forKey: Keys.definitions.rawValue) as? Array<String>,
              let domains = coder.decodeObject(of: [InlineModel9.self], forKey: Keys.domains.rawValue) as? domainsList?,
              let notes = coder.decodeObject(of: [InlineModel4.self], forKey: Keys.notes.rawValue) as? CategorizedTextList?,
              let regions = coder.decodeObject(of: [InlineModel7.self], forKey: Keys.regions.rawValue) as? regionsList?,
              let registers = coder.decodeObject(of: [InlineModel8.self], forKey: Keys.registers.rawValue) as? registersList?,
              let senseIds = coder.decodeObject(of: [NSString.self], forKey: Keys.senseIds.rawValue) as? Array<String>,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding InlineModel12")
        }

        self.definitions = definitions
        self.domains = domains
        self.notes = notes
        self.regions = regions
        self.registers = registers
        self.senseIds = senseIds
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String

        case definitions = "definitions"
        case domains = "domains"
        case notes = "notes"
        case regions = "regions"
        case registers = "registers"
        case senseIds = "senseIds"
        case text = "text"
    }
}

class InlineModel13: NSObject, Codable, NSSecureCoding {
    var id: String
    var text: String
    
    public static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(text, forKey: Keys.text.rawValue)
    }
    
    required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: Keys.id.rawValue) as? String,
              let text = coder.decodeObject(of: NSString.self, forKey: Keys.text.rawValue) as? String else {
            fatalError("Issue decoding InlineModel11")
        }

        self.id = id
        self.text = text
    }
    
    enum Keys: String {
        typealias RawValue = String
        
        case id = "id"
        case text = "text"
    }
}
