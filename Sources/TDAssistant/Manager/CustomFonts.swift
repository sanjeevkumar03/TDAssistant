// CustomFonts.swift
// Copyright © 2024 Telus Digital. All rights reserved.

import Foundation
import UIKit

struct Font {
    enum FontFamily: String {
        case academyEngravedLET = "Academy Engraved LET"
        case alNile = "Al Nile"
        case americanTypewriter = "American Typewriter"
        case appleColorEmoji = "Apple Color Emoji"
        case appleSDGothicNeo = "Apple SD Gothic Neo"
        case appleSymbols = "Apple Symbols"
        case arial = "Arial"
        case arialHebrew = "Arial Hebrew"
        case arialRoundedMTBold = "Arial Rounded MT Bold"
        case avenir = "Avenir"
        case avenirNext = "Avenir Next"
        case avenirNextCondensed = "Avenir Next Condensed"
        case baskerville = "Baskerville"
        case bodoni72 = "Bodoni 72"
        case bodoni72Oldstyle = "Bodoni 72 Oldstyle"
        case bodoni72Smallcaps = "Bodoni 72 Smallcaps"
        case bradleyHand = "Bradley Hand"
        case chalkboardSE = "Chalkboard SE"
        case chalkduster = "Chalkduster"
        case charter = "Charter"
        case cochin = "Cochin"
        case copperplate = "Copperplate"
        case courierNew = "Courier New"
        case damascus = "Damascus"
        case devanagariSangamMN = "Devanagari Sangam MN"
        case didot = "Didot"
        case DINAlternate = "DIN Alternate"
        case DINCondensed = "DIN Condensed"
        case euphemiaUCAS = "Euphemia UCAS"
        case farah = "Farah"
        case futura = "Futura"
        case galvji = "Galvji"
        case geezaPro = "Geeza Pro"
        case georgia = "Georgia"
        case gillSans = "Gill Sans"
        case granthaSangamMN = "Grantha Sangam MN"
        case helvetica = "Helvetica"
        case helveticaNeue = "Helvetica Neue"
        case hiraginoMaruGothicProN = "Hiragino Maru Gothic ProN"
        case hiraginoMinchoProN = "Hiragino Mincho ProN"
        case hiraginoSans = "Hiragino Sans"
        case hoeflerText = "Hoefler Text"
        case impact = "Impact"
        case kailasa = "Kailasa"
        case kefa = "Kefa"
        case khmerSangamMN = "Khmer Sangam MN"
        case laoSangamMN = "Lao Sangam MN"
        case markerFelt = "Marker Felt"
        case menlo = "Menlo"
        case mishafi = "Mishafi"
        case muktaMahee = "Mukta Mahee"
        case noteworthy = "Noteworthy"
        case optima = "Optima"
        case palatino = "Palatino"
        case papyrus = "Papyrus"
        case partyLET = "Party LET"
        case pingFangHK = "PingFang HK"
        case pingFangSC = "PingFang SC"
        case pingFangTC = "PingFang TC"
        case rockwell = "Rockwell"
        case savoyeLET = "Savoye LET"
        case sinhalaSangamMN = "Sinhala Sangam MN"
        case snellRoundhand = "Snell Roundhand"
        case STIXTwoMath = "STIX Two Math"
        case STIXTwoText = "STIX Two Text"
        case thonburi = "Thonburi"
        case timesNewRoman = "Times New Roman"
        case trebuchetMS = "Trebuchet MS"
        case verdana = "Verdana"
        case zapfDingbats = "Zapf Dingbats"
    }

    enum FontName: String {
        case academyEngravedLET = "AcademyEngravedLetPlain"
        case alNile = "AlNile"
        case americanTypewriter = "AmericanTypewriter"
        case appleColorEmoji = "AppleColorEmoji"
        case appleSDGothicNeo = "AppleSDGothicNeo-Regular"
        case appleSymbols = "AppleSymbols"
        case arial = "ArialMT"
        case arialHebrew = "ArialHebrew"
        case arialRoundedMTBold = "ArialRoundedMTBold"
        case avenir = "Avenir-Book"
        case avenirNext = "AvenirNext-Regular"
        case avenirNextCondensed = "AvenirNextCondensed-Regular"
        case baskerville = "Baskerville"
        case bodoni72 = "BodoniSvtyTwoITCTT-Book"
        case bodoni72Oldstyle = "BodoniSvtyTwoOSITCTT-Book"
        case bodoni72Smallcaps = "BodoniSvtyTwoSCITCTT-Book"
        case bradleyHand = "BradleyHandITCTT-Bold"
        case chalkboardSE = "ChalkboardSE-Regular"
        case chalkduster = "Chalkduster"
        case charter = "Charter-Roman"
        case cochin = "Cochin"
        case copperplate = "Copperplate"
        case courierNew = "CourierNewPSMT"
        case damascus = "Damascus"
        case devanagariSangamMN = "DevanagariSangamMN"
        case didot = "Didot"
        case DINAlternate = "DINAlternate-Bold"
        case DINCondensed = "DINCondensed-Bold"
        case euphemiaUCAS = "EuphemiaUCAS"
        case farah = "Farah"
        case futura = "Futura-Medium"
        case galvji = "Galvji"
        case geezaPro = "GeezaPro"
        case georgia = "Georgia"
        case gillSans = "GillSans"
        case granthaSangamMN = "GranthaSangamMN-Regular"
        case helvetica = "Helvetica"
        case helveticaNeue = "HelveticaNeue"
        case hiraginoMaruGothicProN = "HiraMaruProN-W4"
        case hiraginoMinchoProN = "HiraMinProN-W3"
        case hiraginoSans = "HiraginoSans-W3"
        case hoeflerText = "HoeflerText-Regular"
        case impact = "Impact"
        case kailasa = "Kailasa"
        case kefa = "Kefa-Regular"
        case khmerSangamMN = "KhmerSangamMN"
        case laoSangamMN = "LaoSangamMN"
        case markerFelt = "MarkerFelt-Thin"
        case menlo = "Menlo-Regular"
        case mishafi = "DiwanMishafi"
        case muktaMahee = "MuktaMahee-Regular"
        case noteworthy = "Noteworthy-Light"
        case optima = "Optima-Regular"
        case palatino = "Palatino-Roman"
        case papyrus = "Papyrus"
        case partyLET = "PartyLetPlain"
        case pingFangHK = "PingFangHK-Regular"
        case pingFangSC = " PingFangSC-Regular"
        case pingFangTC = "PingFangTC-Regular"
        case rockwell = "Rockwell-Regular"
        case savoyeLET = "SavoyeLetPlain"
        case sinhalaSangamMN = "SinhalaSangamMN"
        case snellRoundhand = "SnellRoundhand"
        case STIXTwoMath = "STIXTwoMath-Regular"
        case STIXTwoText = "STIXTwoText"
        case thonburi = "Thonburi"
        case timesNewRoman = "TimesNewRomanPSMT"
        case trebuchetMS = "TrebuchetMS"
        case verdana = "Verdana"
        case zapfDingbats = "ZapfDingbatsITC"
    }

    static func getFontName(family: String) -> String {
        switch family {
        case FontFamily.academyEngravedLET.rawValue:
            return FontName.academyEngravedLET.rawValue
        case FontFamily.alNile.rawValue:
            return FontName.alNile.rawValue
        case FontFamily.americanTypewriter.rawValue:
            return FontName.americanTypewriter.rawValue
        case FontFamily.appleColorEmoji.rawValue:
            return FontName.appleColorEmoji.rawValue
        case FontFamily.appleSDGothicNeo.rawValue:
            return FontName.appleSDGothicNeo.rawValue
        case FontFamily.appleSymbols.rawValue:
            return FontName.appleSymbols.rawValue
        case FontFamily.arial.rawValue:
            return FontName.arial.rawValue
        case FontFamily.arialHebrew.rawValue:
            return FontName.arialHebrew.rawValue
        case FontFamily.arialRoundedMTBold.rawValue:
            return FontName.arialRoundedMTBold.rawValue
        case FontFamily.avenir.rawValue:
            return FontName.avenir.rawValue
        case FontFamily.avenirNext.rawValue:
            return FontName.avenirNext.rawValue
        case FontFamily.avenirNextCondensed.rawValue:
            return FontName.avenirNextCondensed.rawValue
        case FontFamily.baskerville.rawValue:
            return FontName.baskerville.rawValue
        case FontFamily.bodoni72.rawValue:
            return FontName.bodoni72.rawValue
        case FontFamily.bodoni72Oldstyle.rawValue:
            return FontName.bodoni72Oldstyle.rawValue
        case FontFamily.bodoni72Smallcaps.rawValue:
            return FontName.bodoni72Smallcaps.rawValue
        case FontFamily.bradleyHand.rawValue:
            return FontName.bradleyHand.rawValue
        case FontFamily.chalkboardSE.rawValue:
            return FontName.chalkboardSE.rawValue
        case FontFamily.chalkduster.rawValue:
            return FontName.chalkduster.rawValue
        case FontFamily.charter.rawValue:
            return FontName.charter.rawValue
        case FontFamily.cochin.rawValue:
            return FontName.cochin.rawValue
        case FontFamily.copperplate.rawValue:
            return FontName.copperplate.rawValue
        case FontFamily.courierNew.rawValue:
            return FontName.courierNew.rawValue
        case FontFamily.damascus.rawValue:
            return FontName.damascus.rawValue
        case FontFamily.devanagariSangamMN.rawValue:
            return FontName.devanagariSangamMN.rawValue
        case FontFamily.didot.rawValue:
            return FontName.didot.rawValue
        case FontFamily.DINAlternate.rawValue:
            return FontName.DINAlternate.rawValue
        case FontFamily.DINCondensed.rawValue:
            return FontName.DINCondensed.rawValue
        case FontFamily.euphemiaUCAS.rawValue:
            return FontName.euphemiaUCAS.rawValue
        case FontFamily.farah.rawValue:
            return FontName.farah.rawValue
        case FontFamily.futura.rawValue:
            return FontName.futura.rawValue
        case FontFamily.galvji.rawValue:
            return FontName.galvji.rawValue
        case FontFamily.geezaPro.rawValue:
            return FontName.geezaPro.rawValue
        case FontFamily.georgia.rawValue:
            return FontName.georgia.rawValue
        case FontFamily.gillSans.rawValue:
            return FontName.gillSans.rawValue
        case FontFamily.granthaSangamMN.rawValue:
            return FontName.granthaSangamMN.rawValue
        case FontFamily.helvetica.rawValue:
            return FontName.helvetica.rawValue
        case FontFamily.helveticaNeue.rawValue:
            return FontName.helveticaNeue.rawValue
        case FontFamily.hiraginoMaruGothicProN.rawValue:
            return FontName.hiraginoMaruGothicProN.rawValue
        case FontFamily.hiraginoMinchoProN.rawValue:
            return FontName.hiraginoMinchoProN.rawValue
        case FontFamily.hiraginoSans.rawValue:
            return FontName.hiraginoSans.rawValue
        case FontFamily.hoeflerText.rawValue:
            return FontName.hoeflerText.rawValue
        case FontFamily.impact.rawValue:
            return FontName.impact.rawValue
        case FontFamily.kailasa.rawValue:
            return FontName.kailasa.rawValue
        case FontFamily.kefa.rawValue:
            return FontName.kefa.rawValue
        case FontFamily.khmerSangamMN.rawValue:
            return FontName.khmerSangamMN.rawValue
        case FontFamily.laoSangamMN.rawValue:
            return FontName.laoSangamMN.rawValue
        case FontFamily.markerFelt.rawValue:
            return FontName.markerFelt.rawValue
        case FontFamily.menlo.rawValue:
            return FontName.menlo.rawValue
        case FontFamily.mishafi.rawValue:
            return FontName.mishafi.rawValue
        case FontFamily.muktaMahee.rawValue:
            return FontName.muktaMahee.rawValue
        case FontFamily.noteworthy.rawValue:
            return FontName.noteworthy.rawValue
        case FontFamily.optima.rawValue:
            return FontName.optima.rawValue
        case FontFamily.palatino.rawValue:
            return FontName.palatino.rawValue
        case FontFamily.papyrus.rawValue:
            return FontName.papyrus.rawValue
        case FontFamily.partyLET.rawValue:
            return FontName.partyLET.rawValue
        case FontFamily.pingFangHK.rawValue:
            return FontName.pingFangHK.rawValue
        case FontFamily.pingFangSC.rawValue:
            return FontName.pingFangSC.rawValue
        case FontFamily.pingFangTC.rawValue:
            return FontName.pingFangTC.rawValue
        case FontFamily.rockwell.rawValue:
            return FontName.rockwell.rawValue
        case FontFamily.savoyeLET.rawValue:
            return FontName.savoyeLET.rawValue
        case FontFamily.sinhalaSangamMN.rawValue:
            return FontName.sinhalaSangamMN.rawValue
        case FontFamily.snellRoundhand.rawValue:
            return FontName.snellRoundhand.rawValue
        case FontFamily.STIXTwoMath.rawValue:
            return FontName.STIXTwoMath.rawValue
        case FontFamily.STIXTwoText.rawValue:
            return FontName.STIXTwoText.rawValue
        case FontFamily.thonburi.rawValue:
            return FontName.thonburi.rawValue
        case FontFamily.timesNewRoman.rawValue:
            return FontName.timesNewRoman.rawValue
        case FontFamily.trebuchetMS.rawValue:
            return FontName.trebuchetMS.rawValue
        case FontFamily.verdana.rawValue:
            return FontName.verdana.rawValue
        case FontFamily.zapfDingbats.rawValue:
            return FontName.zapfDingbats.rawValue
        default:
            return FontName.helvetica.rawValue
        }
    }

    enum FontType {
        case installed(FontName)
        case custom(String)
        case system
        case systemBold
        case systemItatic
    }

    enum FontSize {
        case standard(StandardSize)
        case custom(Double)
        var value: Double {
            switch self {
            case .standard(let size):
                return size.rawValue
            case .custom(let customSize):
                return customSize
            }
        }
    }

    enum StandardSize: Double {
        case extraLarge = 20.0
        case large = 18.0
        case normal = 16.0
        case medium = 14.0
        case small = 12.0
        case extraSmall = 10.0
        case tiny = 8.0
    }

    var type: FontType
    var size: FontSize
    init(_ type: FontType, size: FontSize) {
        self.type = type
        self.size = size
    }
}

extension Font {
    var instance: UIFont {
        var instanceFont: UIFont!
        switch type {
        case .custom(let fontName):
            guard let font =  UIFont(name: fontName, size: CGFloat(size.value)) else {
                fatalError("\(fontName) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case .installed(let fontName):
            guard let font =  UIFont(name: fontName.rawValue, size: CGFloat(size.value)) else {
                fatalError("\(fontName.rawValue) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case .system:
            instanceFont = UIFont.systemFont(ofSize: CGFloat(size.value))
        case .systemBold:
            instanceFont = UIFont.boldSystemFont(ofSize: CGFloat(size.value))
        case .systemItatic:
            instanceFont = UIFont.italicSystemFont(ofSize: CGFloat(size.value))
        }
        return instanceFont
    }
}

class Utility {
    /// Logs all available fonts from iOS SDK and installed custom font
    class func logAllAvailableFonts() {
        for family in UIFont.familyNames {
            //print("\(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
    }
}
/// Used to check whether font is bold or italic
extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }

    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}

class GenAIFonts {
    func bold(fontSize: CGFloat = 14) -> UIFont? {
        return UIFont(name: "Helvetica-Bold", size: fontSize)
    }
    
    func normal(fontSize: CGFloat = 14) -> UIFont? {
        return UIFont(name: "Helvetica", size: fontSize)
    }
}
