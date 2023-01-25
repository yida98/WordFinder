//
//  SearchToolbar.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/21/22.
//

import SwiftUI

struct SearchToolbar: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var scrollViewContentSize: CGSize = .zero
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                GeometryReader { geometryProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        WordCellClusterView(viewModel: viewModel, scrollProxy: scrollViewProxy)
                            .frame(minWidth: geometryProxy.size.width)
                    }
                }
            }
        }.padding(.vertical, 6)
    }
}
