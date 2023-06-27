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
        if let definitions = retrieveEntry.def {
            VStack {
                ForEach(definitions.indices, id: \.self) { definitionIndex in
                    MWDefinitionView(definition: definitions[definitionIndex])
                }
            }
        } else {
            EmptyView()
        }
    }
}
