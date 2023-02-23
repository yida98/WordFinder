//
//  Color_ext.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/7/22.
//

import Foundation
import SwiftUI

extension Color {
    static let lightGrey: Color = Color(white: 0.9)
    static let raisonBlack: Color = Color(red: 57/255, green: 54/255, blue: 64/255)
    
    // MARK: Blue
    static let babyPowder: Color = Color(red: 252/255, green: 251/255, blue: 247/255)
    static let blueCrayola: Color = Color(red: 22/255, green: 115/255, blue: 255/255)
    static let boyBlue: Color = Color(red: 95/255, green: 159/255, blue: 255/255)
    static let darkSkyBlue: Color = Color(red: 116/255, green: 179/255, blue: 206/255)
    static let uranianBlue: Color = Color(red: 186/255, green: 222/255, blue: 255/255)
    static let beauBlue: Color = Color(red: 182/255, green: 204/255, blue: 224/255)
    static let magnolia: Color = Color(red: 248/255, green: 242/255, blue: 252/255)
    static let lavendarGray: Color = Color(red: 193/255, green: 185/255, blue: 201/255)
    static let moodPurple: Color = Color(red: 130/255, green: 119/255, blue: 137/255)
    static let sonicSilver: Color = Color(red: 127/255, green: 121/255, blue: 121/255)
    static let thistle: Color = Color(red: 213/255, green: 197/255, blue: 227/255)
    
    // MARK: Green
    static let yellowGreenCrayola: Color = Color(red: 181/255, green: 239/255, blue: 138/255)
    static let hunterGreen: Color = Color(red: 69/255, green: 107/255, blue: 76/255)
    static let morningBlue: Color = Color(red: 130/255, green: 158/255, blue: 135/255)
    static let morningDustBlue: Color = Color(red: 192/255, green: 206/255, blue: 195/255)
    static let darkSeaGreen: Color = Color(red: 156/255, green: 186/255, blue: 141/255)
    static let commonGreen: Color = Color(red: 125/255, green: 219/255, blue: 134/255)
    static let teaGreen: Color = Color(red: 194/255, green: 233/255, blue: 190/255)
    static let mantis: Color = Color(red: 116/255, green: 205/255, blue: 106/255)
    static let forestGreen: Color = Color(red: 54/255, green: 134/255, blue: 45/255)
    static let hunterGreen2: Color = Color(red: 38/255, green: 96/255, blue: 32/255)
    
    static let greenGradientSet: [Color] = [.teaGreen, .mantis, .forestGreen, .hunterGreen2]
    
    // MARK: Red
    static let redwood: Color = Color(red: 158/255, green: 83/255, blue: 70/255)
}

struct ColorSet {
    var primaryFill: Color
    var secondaryFill: Color
    var shadowFill: Color
    var primaryHighlight: Color
    var secondaryHighlight: Color?
}
