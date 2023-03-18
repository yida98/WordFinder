//
//  Font+ext.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/17/23.
//

import Foundation
import SwiftUI

extension Font {

    /// Create a font with the large title text style.
    public static var largeTitleBaskerville: Font {
        return Font.custom("Baskerville", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize + 10).uppercaseSmallCaps()
    }

    /// Create a font with the title text style.
    public static var titleBaskerville: Font {
        return Font.custom("Baskerville", size: UIFont.preferredFont(forTextStyle: .title1).pointSize).uppercaseSmallCaps()
    }

    /// Create a font with the headline text style.
    public static var headlineBaskerville: Font {
        return Font.custom("Baskerville", size: UIFont.preferredFont(forTextStyle: .headline).pointSize)
    }

    /// Create a font with the subheadline text style.
    public static var subheadlineBaskerville: Font {
        return Font.custom("Baskerville", size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize)
    }

    /// Create a font with the body text style.
    public static var bodyBaskerville: Font {
           return Font.custom("Baskerville", size: UIFont.preferredFont(forTextStyle: .body).pointSize)
       }

    /// Create a font with the callout text style.
    public static var calloutBaskerville: Font {
           return Font.custom("Baskerville", size: UIFont.preferredFont(forTextStyle: .callout).pointSize)
       }

    /// Create a font with the footnote text style.
    public static var footnoteBaskerville: Font {
           return Font.custom("Baskerville", size: UIFont.preferredFont(forTextStyle: .footnote).pointSize)
       }

    /// Create a font with the caption text style.
    public static var captionBaskerville: Font {
        return Font.custom("Baskerville", size: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
       }
    
    public static var largeTitleQuiz: Font {
        return Font.system(.largeTitle).uppercaseSmallCaps().monospaced()
    }
    
    public static var subheadlineQuiz: Font {
        return Font.system(.subheadline).monospaced()
    }

    public static var bodyQuiz: Font {
        return Font.system(.caption).monospaced()
    }
    
    public static var bodyQuiz2: Font {
        return Font.system(.body).monospaced()
    }
    
    public static var calloutQuiz: Font {
        return Font.system(.callout).monospaced()
    }
    
    public static var footnoteQuiz: Font {
        return Font.system(.footnote).monospaced()
    }
    
    public static var captionQuiz: Font {
        return Font.system(.caption).monospaced()
    }

//    public static func system(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
//        var font = "Baskerville"
//        switch weight {
//        case .bold: font = "Baskerville-Bold"
//        case .heavy: font = "Baskerville-ExtraBold"
//        case .light: font = "Baskerville-Light"
//        case .medium: font = "Baskerville-Regular"
//        case .semibold: font = "Baskerville-SemiBold"
//        case .thin: font = "Baskerville-Light"
//        case .ultraLight: font = "Baskerville-Light"
//        default: break
//        }
//        return Font.custom(font, size: size)
//    }
}
