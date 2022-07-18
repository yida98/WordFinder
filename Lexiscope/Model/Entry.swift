//
//  Entry.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/11/22.
//

import Foundation

/// Model transcribed from *Oxford Dictionary* https://developer.oxforddictionaries.com/documentation
struct OxfordEntry {
    struct RetrieveEntry { // TODO: Codable
        var metadata: Dictionary<String, String>?
        var results: Array<HeadwordEntry>?
    }

    struct HeadwordEntry: Identifiable { // TODO: Codable
        var id: String
        var language: String
        var lexicalEntries: Array<LexicalEntry>
        var pronunciations: PronunciationsList?
        var type: String?
        var word: String
    }

    struct LexicalEntry: Identifiable { // TODO: Codable
        var entries: Array<Entry>
        var language: String
        var lexicalCategory: LexicalCategory
        var root: String?
        var text: String
        var id: String {
            return lexicalCategory.id
        }
        
    }

    // FIXME: What are these
    typealias PronunciationsList = Array<InlineModel1>
    typealias ArrayOfRelatedEntries = Array<InlineModel2>

    struct Entry: Identifiable { // TODO: Codable
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
    }

    typealias GrammaticalFeaturesList = [InlineModel3]

    struct LexicalCategory {
        var id: String
        var text: String
    }

    typealias CategorizedTextList = [InlineModel4]
    typealias VariantFormsList = [InlineModel5]

    typealias CrossReferencesList = [InlineModel6]

    struct InflectedForm {
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
    }

    struct Sense {
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
    }

    typealias regionsList = Array<InlineModel7>
    typealias registersList = Array<InlineModel8>
    typealias domainsList = Array<InlineModel9>

    typealias SynonymsAntonyms = InlineModel10

    typealias domainClassesList = Array<InlineModel11>
    typealias ExamplesList = Array<InlineModel12>
    typealias semanticClassesList = Array<InlineModel13>

    struct thesaurusLink {
        /// identifier of a word.
        var entry_id: String
        /// identifier of a sense.
        var sense_id: String
    }

    typealias ExampleText = String
    /*
     Inline Model 1
     
     struct Pronunciation: Codable {
         var audioFile: String?
         var phoneticNotation: String?
         var phoneticSpelling: String?
         
     //    init(from decoder: Decoder) throws {
     //        let container = try decoder.container(keyedBy: Keys.self)
     //        let audioFile = try container.decode(String.self, forKey: .audioFile)
     //        self.audioFile = audioFile
     //        let phoneticNotation = try container.decode(String.self, forKey: .phoneticNotation)
     //        self.phoneticNotation = phoneticNotation
     //        do {
     //            let phoneticSpelling = try container.decode(String.self, forKey: .phoneticSpelling)
     //            self.phoneticSpelling = phoneticSpelling.unicodeScalars.first
     //            print(phoneticSpelling)
     //        } catch {
     //            print(error)
     //        }
     //    }
     //
     //    func encode(to encoder: Encoder) throws {
     //        var container = encoder.container(keyedBy: Keys.self)
     //        try container.encode(self.audioFile, forKey: .audioFile)
     //        try container.encode(self.phoneticNotation, forKey: .phoneticNotation)
     //        guard let ps = self.phoneticSpelling else {
     //
     //            return
     //        }
     //        try container.encode(ps.escaped(asASCII: false), forKey: .phoneticSpelling)
     //    }
     //
     //    enum Keys: CodingKey {
     //        case audioFile
     //        case phoneticNotation
     //        case phoneticSpelling
     //    }
         
     }

//    struct Category: Identifiable { // TODO: Codable
//        var id: String
//        var text: String
//    }
//
//    struct Sense: Identifiable { // TODO: Codable
//        var definitions: Array<String>?
//        var id: String?
//        var subsenses: Array<Sense>?
//    }
     
     */

    // MARK: - Inline Models

    struct InlineModel1 {
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
    }

    struct InlineModel2 {
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
    }

    struct inline_model_2 {
        var domains: domainsList?
        var examples: Array<ExampleText>?
        var notes: CategorizedTextList?
        var regions: regionsList?
        var registers: registersList?
        /// The construction text.
        var text: String
    }

    struct InlineModel3 {
        var id: String
        var text: String
        var type: String
    }

    struct InlineModel4 {
        /// The identifier of the word.
        var id: String?
        /// A note text.
        var text: String
        /// The descriptive category of the text.
        var type: String
    }

    struct InlineModel5 {
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
    }

    struct InlineModel6 {
        /// The word id of the co-occurrence.
        var id: String
        /// The word of the co-occurrence.
        var text: String
        /// The type of relation between the two words. Possible values are 'close match', 'related', 'see also', 'variant spelling', and 'abbreviation' in case of crossreferences, or 'pre', 'post' in case of collocates.
        var type: String
    }

    struct InlineModel7 {
        var id: String
        var text: String
    }

    struct InlineModel8 {
        var id: String
        var text: String
    }

    struct InlineModel9 {
        var id: String
        var text: String
    }

    struct InlineModel10 {
        var domains: domainsList?
        var id: String?
        var language: String?
        ///  A particular area in which the Sense occurs, e.g. 'Great Britain'.
        var regions: regionsList?
        /// A level of language usage, typically with respect to formality. e.g. 'offensive', 'informal'.
        var registers: registersList?
        var text: String
    }

    struct InlineModel11 {
        var id: String
        var text: String
    }

    struct InlineModel12 {
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
    }

    struct InlineModel13 {
        var id: String
        var text: String
    }
}
