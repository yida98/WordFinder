//
//  ScannerView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/7/22.
//

import Foundation
import SwiftUI

struct ScannerView: View {
    @EnvironmentObject var viewModel: ScannerViewModel
    
    var body: some View {
        ZStack {
            Text(viewModel.resultCluster)
            // FIXME: Negative frame, coordinates.width
            RoundedRectangle(cornerRadius: 0) // TODO: Theme
                .foregroundColor(Color.darkSkyBlue.opacity(0.3))
                .frame(width: viewModel.coordinates.width,
                       height: viewModel.coordinates.height)
                .position(x: viewModel.coordinates.midX,
                          y: viewModel.coordinates.midY)
        }
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        
    }
}
