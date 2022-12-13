//
//  ScannerView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/7/22.
//

import Foundation
import SwiftUI

struct ScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel
    
    var body: some View {
        ZStack {
            if viewModel.coordinates != .zero {
            // FIXME: Negative frame, coordinates.
                Rectangle()
                    .foregroundColor(.black.opacity(0.5))
                    .mask {
                            Window(coordinates: viewModel.coordinates).fill(style: FillStyle(eoFill: true))
                        }
                }
        }
    }
}

struct Window: Shape {
    let coordinates: CGRect
    func path(in rect: CGRect) -> Path {
        var path = Rectangle().path(in: rect)
        
        path.addRect(coordinates)
        return path
    }
}

extension CGRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        
    }
}
