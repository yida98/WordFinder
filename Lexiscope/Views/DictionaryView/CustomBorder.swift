//
//  CustomBorder.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/8/22.
//

import Foundation
import SwiftUI

struct CustomBorder: Shape {

    var width: CGFloat
    var edges: [Point]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                default: return 0
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                default: return 0
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                default: return 0
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                default: return 0
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

//struct Edges: OptionSet {
//    let rawValue: Int
//
//    static let leading =    Edges(rawValue: 1 << 0)
//    static let trailing =   Edges(rawValue: 1 << 1)
//    static let top =        Edges(rawValue: 1 << 2)
//    static let bottom =     Edges(rawValue: 1 << 3)
//
//    static let vertical: Edges = [.top, .bottom]
//    static let horizontal: Edges = [.leading, .trailing]
//    static let all: Edges = [.vertical, .horizontal]
//
//}


struct Point: OptionSet {
    let rawValue: Int
    
    static let topLeft =        Point(rawValue: 1 << 0)
    static let topRight =       Point(rawValue: 1 << 1)
    static let bottomLeft =     Point(rawValue: 1 << 2)
    static let bottomRight =    Point(rawValue: 1 << 3)
    static let centre =         Point(rawValue: 1 << 4)
    
    static let leading: Point = [.topLeft, .bottomLeft]
    static let trailing: Point = [.topRight, .bottomRight]
    static let top: Point = [.topRight, .topLeft]
    static let bottom: Point = [.bottomRight, .bottomLeft]
    static let all: Point = [.leading, .trailing, .centre]
    
}
