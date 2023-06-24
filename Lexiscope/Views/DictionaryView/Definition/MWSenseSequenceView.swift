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
        VStack {
            ForEach(sequence.senses.indices, id: \.self) { index in
                MWSenseSequenceElement(sense: sequence.senses[index])
            }
        }
    }
    
    struct MWSenseSequenceElement: View {
        var sense: MWSenseSequence.Element
        
        var body: some View {
            switch sense {
            case .senses(let senseContainer):
                MWSenseContainerView(senses: senseContainer)
            case .sense(let sense):
                SenseView(sense: sense)
            case .pseq(let senseContainer):
                MWSenseContainerView(senses: senseContainer)
            }
        }
        
        struct MWSenseContainerView: View {
            var senses: MWSenseSequence.Element.SenseContainer
            
            var body: some View {
                ForEach(senses.senses.indices, id: \.self) { index in
                    viewForSenseElement(senses.senses[index])
                }
            }
            
            @ViewBuilder
            func viewForSenseElement(_ sense: MWSenseSequence.Element.SenseContainer.Element) -> some View {
                switch sense {
                case .sense(let obj):
                    SenseView(sense: obj)
                case .sen(let sen):
                    TruncatedSenseView(sen: sen)
                case .bs(let bs):
                    SenseView(sense: bs)
                }
            }
            
            func leadingPadding(sn: String) -> CGFloat {
                if let first = sn.first {
                    if first.isLetter {
                        return 10
                    } else if first.isPunctuation {
                        return 20
                    }
                }
                return 0
            }
        }
        
        struct UsageNotesView: View {
            var usageNotes: MWSenseSequence.DefiningText.Element.UsageNotes
            
            var body: some View {
                VStack {
                    ForEach(usageNotes.flatNoteValues.indices, id: \.self) { index in
                        Text(usageNotes.flatNoteValues[index]) // TODO: Usage notes style. Maybe a line to the left, or a box.
                    }
                }
            }
        }
        
        struct VerbalIllustrationView: View {
            var verbalIllustration: MWSenseSequence.DefiningText.Element.VerbalIllustration
            
            var body: some View {
                VStack {
                    ForEach(verbalIllustration.content.indices, id: \.self) { index in
                        Text(verbalIllustration.content[index].t)
                    }
                }
            }
        }
        
        struct TruncatedSenseView: View {
            var sen: MWSenseSequence.Element.SenseContainer.Element.Sen
            // TODO: Handel prs separately
            // TODO: Handle sn just like everyone else
            // TODO: Sense style
            var body: some View {
                Text(sen.inlineStringDisplay())
            }
        }
        
        struct SenseView: View {
            var sense: MWSenseSequence.Element.Sense
            
            var body: some View {
                HStack {
                    if let sn = sense.sn {
                        Text(sn)
                    }
                    if let sls = sense.sls {
                        ForEach(sls.indices, id: \.self) { index in
                            if let label = sls[index].label {
                                Text(label) // TODO: sls label style
                            }
                        }
                    }
                    if let text = sense.dt.content {
                        VStack {
                            ForEach(text.indices, id: \.self) { definingTextIndex in
                                if case .dt(let value) = text[definingTextIndex] {
                                    Text(value.text)
                                } else if case .uns(let usageNotes) = text[definingTextIndex] {
                                    UsageNotesView(usageNotes: usageNotes)
                                } else if case .vis(let verbalIllustration) = text[definingTextIndex] {
                                    VerbalIllustrationView(verbalIllustration: verbalIllustration)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
