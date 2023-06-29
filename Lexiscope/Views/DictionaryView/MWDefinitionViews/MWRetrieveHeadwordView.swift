//
//  MWRetrieveHeadwordView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 6/26/23.
//

import SwiftUI

struct MWRetrieveHeadwordView: View {
    var retrieveEntry: MWRetrieveEntry
    
    @State var presentAlert: Bool = false
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                HStack {
                    if let functionLabel = retrieveEntry.fl {
                        Text(functionLabel)
                            .font(.headlinePrimary)
                            .foregroundColor(Color.pineGreen)
                    }
                    if let lbs = retrieveEntry.lbs {
                        Labels(labels: lbs)
                    }
                    Spacer(minLength: 0)
                }
                if let variants = retrieveEntry.vrs {
                    SubheadlineText(text: MWVariant.joinedLabel(vrs: variants))
                }
                
                if let label = retrieveEntry.inflectionLabel(), !label.isEmpty {
                    SubheadlineText(text: label)
                }
                
                if let cxs = retrieveEntry.cxs {
                    HStack {
                        Text("Variant")
                            .senseLabel()
                        SubheadlineText(text: MWCognateCrossReferences.crossReferenceLabel(cxs))
                        Spacer()
                    }
                }
            }
            
            if let definitions = retrieveEntry.def {
                VStack(spacing: 20) {
                    ForEach(definitions.indices, id: \.self) { definitionIndex in
                        MWDefinitionView(definition: definitions[definitionIndex])
                    }
                }
            }
        }
    }
}

struct Labels: View {
    var labels: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(labels.indices, id: \.self) { lbsIndex in
                    Text(labels[lbsIndex])
                        .senseLabel()
                }
            }
        }
    }
}

struct SubheadlineText: View {
    var text: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(text.localizedTokenizedString())
                .font(.subheadlinePrimary)
                .foregroundColor(.gray)
        }
    }
}

extension View {
    func senseLabel() -> some View {
        self
            .font(.caption)
            .foregroundColor(.gray.opacity(0.4))
            .padding(2)
            .padding(.horizontal, 2)
            .background(RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.2)))
    }
}
