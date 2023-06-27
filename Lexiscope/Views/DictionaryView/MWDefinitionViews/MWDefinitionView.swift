//
//  MWDefinitionView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/21/23.
//

import SwiftUI

struct MWDefinitionView: View {
    var definition: MWDefinition
    
    var body: some View {
        VStack {
            if let verbDivider = definition.vd {
                Text(verbDivider.localizedTokenizedString()) // TODO: Color
                    .italic()
            }
            if let sseq = definition.sseq {
                VStack {
                    ForEach(sseq.indices, id: \.self) { senseIndex in
                        MWSenseSequenceView(sequence: sseq[senseIndex]) // This is the large number (i.e. whole number with no punctuations)
                    }
                }
            }
        }
    }
}
