//
//  FuriganaLayoutManager.swift
//
//  Created by adunne on 7/22/16.
//  Copyright © 2016 Adrian Dunne. All rights reserved.
//
/**
 *
 * Ruby Annotation in Japanese Language:
 * ルビ: http://ja.wikipedia.org/wiki/ルビ
 * 熟字訓: http://zh.wikipedia.org/wiki/熟字訓
 * 当て字: http://ja.wikipedia.org/wiki/当て字
 *
 */

import UIKit

// [Yan Li]
// Set kFuriganaDebugging to true enables glyph rect border
private let kFuriganaDebugging = false

let kDefaultFuriganaKerningControlCharacter = " "
let kDefaultFuriganaFontMultiple: CGFloat = 2

class FuriganaLayoutManager: NSLayoutManager
{
    var textOffsetMultiple: CGFloat = 0
    
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint)
    {
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        
        let attributesToEnumerate = characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        
        textStorage?.enumerateAttribute(NSAttributedString.Key(rawValue: kFuriganaAttributeName), in: attributesToEnumerate, options: []) { (attributeValue, range, _) in
            if let furiganaStringRepresentation = attributeValue as? String
            {
                if let furiganaText = FuriganaTextFromStringRepresentation(furiganaStringRepresentation as NSString)
                {
                    let font = self.textStorage!.attribute(NSAttributedString.Key.font, at: range.location, effectiveRange: nil) as! UIFont
                    let color = self.textStorage!.attribute(NSAttributedString.Key.foregroundColor, at: range.location, effectiveRange: nil) as? UIColor
                    
                    self.drawFurigana(furiganaText, characterRange: range, characterFont: font, textColor: color)
                }
            }
        }
    }
    
    fileprivate func drawFurigana(_ text: NSString, characterRange: NSRange, characterFont: UIFont, textColor: UIColor?)
    {
        let glyphRange = self.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)
        let glyphContainer = textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil)!
        var glyphBounds = boundingRect(forGlyphRange: glyphRange, in: glyphContainer)
        
        let characterFontSize = characterFont.pointSize
        let furiganaFontSize = characterFontSize / kDefaultFuriganaFontMultiple
        let furiganaFont = UIFont.systemFont(ofSize: furiganaFontSize)
        
        glyphBounds.origin.y = glyphBounds.minY + glyphBounds.height * textOffsetMultiple
        
        let paragrapStyle = NSMutableParagraphStyle()
        paragrapStyle.alignment = .left
        paragrapStyle.lineBreakMode = .byClipping
        paragrapStyle.paragraphSpacing = 0.25 * characterFont.lineHeight
        
        var furiganaAttributes = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font) : furiganaFont,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle) : paragrapStyle,
            ]
        
        if let color = textColor
        {
            furiganaAttributes[convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor)] = color
        }
        
        text.draw(in: glyphBounds, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(furiganaAttributes))
        
        if kFuriganaDebugging
        {
            UIColor.red.setStroke()
            UIBezierPath(rect: glyphBounds).stroke()
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
