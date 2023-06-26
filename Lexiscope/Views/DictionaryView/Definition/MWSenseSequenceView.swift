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
                    ForEach(usageNotes.flatNoteValues.indices, id: \.self) { index in
                        Text(usageNotes.flatNoteValues[index]) // TODO: Usage notes style. Maybe a line to the left, or a box.
                    }
                }
            }
        }
        
        struct VerbalIllustrationView: View {
            var verbalIllustration: MWSenseSequence.DefiningText.VerbalIllustration
            
            var body: some View {
                VStack {
                    ForEach(verbalIllustration.content.indices, id: \.self) { index in
                        Text(verbalIllustration.content[index].t)
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
                    VStack {
                        Text(sense.dt.text) // TODO: DefiningText regular font
                        if let uns = sense.dt.uns {
                            UsageNotesView(usageNotes: uns)
                        }
                        if let vis = sense.dt.vis {
                            VerbalIllustrationView(verbalIllustration: vis)
                        }
                    }
                }
            }
        }
    }
}
