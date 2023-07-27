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
        VStack(spacing: 4) {
            if let verbDivider = definition.vd {
                HStack {
                    Text(verbDivider.localizedTokenizedString()) // TODO: Color
                        .font(.subheadlinePrimary)
                        .foregroundColor(.verdigris)
                    Spacer(minLength: 0)
                }
            }
            if let sseq = definition.sseq {
                VStack(spacing: 20) {
                    ForEach(sseq.indices, id: \.self) { senseIndex in
                        MWSenseSequenceView(sequence: sseq[senseIndex]) // This is the large number (i.e. whole number with no punctuations)
                    }
                }
            }
        }
    }
}
