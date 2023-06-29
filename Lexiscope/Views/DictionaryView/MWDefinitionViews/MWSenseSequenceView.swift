//
//  MWSenseSequenceView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/24/23.
//

import SwiftUI

struct MWSenseSequenceView: View {
    var sequence: MWSenseSequence
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(sequence.senses.indices, id: \.self) { index in
                MWSenseSequenceElement(sense: sequence.senses[index])
            }
        }
    }
    
    struct MWSenseSequenceElement: View {
        var sense: MWSenseSequence.Element
        
        var body: some View {
            switch sense {
            case .sense(let sense):
                SenseView(sense: sense)
            case .pseq(let sequence):
                MWSenseSequenceView(sequence: sequence)
            case .sen(let sen):
                TruncatedSenseView(sen: sen)
            case .bs(let bs):
                SenseView(sense: bs)
            }
        }
        
        struct UsageNotesView: View {
            var usageNotes: MWSenseSequence.DefiningText.UsageNotes
            
            var body: some View {
                VStack {
                    ForEach(usageNotes.notes.indices, id: \.self) { index in
                        ForEach(usageNotes.notes[index].values.indices, id: \.self) { noteIndex in
                            switch usageNotes.notes[index].values[noteIndex] {
                            case .vis(let vis):
                                VerbalIllustrationView(verbalIllustration: vis)
                            case .textValue(let text):
                                Text("\u{2014} \(text)".localizedTokenizedString())
                                    .senseParagraph()
                            }
                        }
                    }
                }
            }
        }
        
        struct VerbalIllustrationView: View {
            var verbalIllustration: MWSenseSequence.DefiningText.VerbalIllustration
            
            var body: some View {
                VStack {
                    ForEach(verbalIllustration.content.indices, id: \.self) { index in
                        HStack {
                            Rectangle()
                                .fill(Color(white: 0.8))
                                .frame(width: 2)
                            Text(verbalIllustration.content[index].t.localizedTokenizedString())
                                .font(.footnotePrimary)
                                .foregroundColor(Color(white: 0.6))
                            Spacer()
                        }
                    }
                }
            }
        }
        
        struct SupplementalInformationNoteView: View {
            var snote: MWSenseSequence.DefiningText.SupplementalInformationNote
            
            var body: some View {
                VStack {
                    ForEach(snote.notes.indices, id: \.self) { noteIndex in
                        switch snote.notes[noteIndex] {
                        case .t(let text):
                            Text(text.localizedTokenizedString())
                                .font(.bodyPrimary)
                                .foregroundColor(Color(white: 0.6))
                                .lineSpacing(6)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        case .vis(let vis):
                            VerbalIllustrationView(verbalIllustration: vis)
                        }
                    }
                }
            }
        }
        
        struct TruncatedSenseView: View {
            var sen: MWSenseSequence.Element.Sen
            // TODO: Handel prs separately
            // TODO: Handle sn just like everyone else
            // TODO: Sense style
            var body: some View {
                Text(sen.inlineStringDisplay().localizedTokenizedString())
                    .senseParagraph()
            }
        }
        
        struct SenseView: View {
            var sense: MWSenseSequence.Element.Sense
            
            var body: some View {
                HStack {
                    if let sn = sense.sn {
                        SenseNumber(sn)
                    }
                    VStack(spacing: 6) {
                        if let sls = sense.sls {
                            Labels(labels: sls.compactMap { $0.label })
                        }
                        // MARK: Defining text
                        Text(sense.dt.text.localizedTokenizedString()) // TODO: DefiningText regular font
                            .senseParagraph()
                        if let sdsense = sense.sdsense {
                            Group {
                                Text(sdsense.fullLabel().localizedTokenizedString())
                            }.senseParagraph()
                        }
                        if let uns = sense.dt.uns {
                            UsageNotesView(usageNotes: uns)
                        }
                        if let snote = sense.dt.snote {
                            SupplementalInformationNoteView(snote: snote)
                        }
                        if let vis = sense.dt.vis {
                            VerbalIllustrationView(verbalIllustration: vis)
                        }
                        Spacer()
                    }
                }
            }
            
            struct SenseNumber: View {
                var sn: String
                
                init(_ sn: String) {
                    self.sn = sn
                }
                
                var body: some View {
                    HStack(spacing: 0) {
                        ForEach(sn.senseNumberGroups().indices, id: \.self) { index in
                            VStack {
                                Text(sn.senseNumberGroups()[index])
                                    .font(.bodyPrimaryBold)
                                    .foregroundColor(.verdigris)
                                    .frame(width: space(for: sn.senseNumberGroups()[index]))
                                Spacer(minLength: 0)
                            }
                        }
                        .padding(.leading, leadingPadding(for: sn.senseNumberGroups()[0]))
                    }
                }
                
                private func leadingPadding(for sn: String) -> CGFloat {
                    if let firstCharacter = sn.first {
                        if firstCharacter.isLetter {
                            return space(for: sn)
                        } else if firstCharacter.isPunctuation {
                            return space(for: "1") * 2
                        }
                    }
                    return 0
                }
                
                private func space(for sn: String) -> CGFloat {
                    if let firstCharacter = sn.first {
                        if firstCharacter.isLetter {
                            return 18
                        } else if firstCharacter.isPunctuation {
                            return 26
                        }
                    }
                    return 18
                }
            }
        }
    }
}

struct MWSenseParagraph: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
                .font(.bodyPrimary)
                .foregroundColor(Color(white: 0.4))
                .lineSpacing(6)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}

extension View {
    func senseParagraph(_ sn: String? = nil) -> some View {
        modifier(MWSenseParagraph())
    }
}
