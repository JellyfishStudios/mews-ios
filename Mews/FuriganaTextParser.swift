import Foundation
import UIKit
import CoreText


open class FuriganaTextParser {
    open static func createFuriganaString(_ rubyText: String) -> FuriganaText {
        
        var endPos = 0
        var originalText : String = ""
        var furiganas : [Furigana ] = []
        
        let strings = rubyText
            .replace("<ruby>.+?</ruby>", template: "`$0`")
            .components(separatedBy: "`")
        
        strings.forEach { (x) in
            if let result = x.find("<ruby>(.+?)<rt>(.+?)</rt></ruby>") {
                let tempString = x as NSString
                
                let a = tempString.substring(with: result.rangeAt(1))
                let b = tempString.substring(with: result.rangeAt(2))
                
                endPos += a.characters.count
                
                originalText.append(a)
                
                let startPos = endPos-(a.characters.count)
                furiganas.append(Furigana(text: b, original: a, range: NSMakeRange(startPos, a.characters.count)))
            }
            else {
                endPos += x.characters.count
                
                originalText.append(x)
            }
        }
        
        return FuriganaText(original: originalText, furigana: furiganas)
    }
}
