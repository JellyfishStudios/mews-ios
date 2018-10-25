//
//  FuriganaWordKerner.swift
//
//  Created by adunne on 7/22/16.
//  Copyright © 2016 Adrian Dunne. All rights reserved.
//
//
import UIKit

class FuriganaWordKerner: NSObject, NSLayoutManagerDelegate
{
    
    // MARK: - NSLayoutManager Delegate
    
    func layoutManager(_ layoutManager: NSLayoutManager, shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSLayoutManager.GlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: UIFont, forGlyphRange glyphRange: NSRange) -> Int
    {
        let glyphCount = glyphRange.length
        let textStorageString = layoutManager.textStorage!.string as NSString
        var newProps: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>? = nil
        
        for i in 0..<glyphCount
        {
            let charIndex = charIndexes[i]
            if let _ = layoutManager.textStorage!.attribute(convertToNSAttributedStringKey(kFuriganaAttributeName), at: charIndex, effectiveRange: nil) as? NSString
            {
                if textStorageString.substringAtIndex(charIndex) == kDefaultFuriganaKerningControlCharacter
                {
                    if newProps == nil
                    {
                        let memSize = Int(MemoryLayout<NSLayoutManager.GlyphProperty>.size * glyphCount)
                        newProps = unsafeBitCast(malloc(memSize), to: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>.self)
                        memcpy(newProps, props, memSize)
                    }
                    
                    newProps?[i] = .controlCharacter
                }
            }
        }
        
        if newProps != nil
        {
            layoutManager.setGlyphs(glyphs, properties: newProps!, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
            free(newProps)
            return glyphCount
        }
        else
        {
            return 0
        }
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, shouldUse action: NSLayoutManager.ControlCharacterAction, forControlCharacterAt charIndex: Int) -> NSLayoutManager.ControlCharacterAction
    {
        if layoutManager.textStorage!.attribute(convertToNSAttributedStringKey(kFuriganaAttributeName), at: charIndex, effectiveRange: nil) != nil
        {
            return .whitespace
        }
        
        return action
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, boundingBoxForControlGlyphAt glyphIndex: Int, for textContainer: NSTextContainer, proposedLineFragment proposedRect: CGRect, glyphPosition: CGPoint, characterIndex charIndex: Int) -> CGRect
    {
        var width: CGFloat = 0
        
        if let furiganaAttributeValue = layoutManager.textStorage?.attribute(convertToNSAttributedStringKey(kFuriganaAttributeName), at: charIndex, effectiveRange: nil) as? NSString
        {
            if let furiganaText = FuriganaTextFromStringRepresentation(furiganaAttributeValue),
                let originalText = FuriganaOriginalTextFromStringrepresentation(furiganaAttributeValue)
            {
                let originalFont = layoutManager.textStorage!.attribute(NSAttributedString.Key.font, at: charIndex, effectiveRange: nil) as! UIFont
                let furiganaFont = originalFont.withSize(originalFont.pointSize / kDefaultFuriganaFontMultiple)
                
                let originalWidth = originalText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : originalFont])).width
                let furiganaWidth = furiganaText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font) : furiganaFont])).width
                
                width = ceil((furiganaWidth - originalWidth) / 2)
                if width < 0
                {
                    width = 0
                }
            }
        }
        
        return CGRect(x: glyphPosition.x, y: glyphPosition.y, width: width, height: proposedRect.height)
    }
    
    func layoutManager(_ layoutManager: NSLayoutManager, shouldBreakLineByWordBeforeCharacterAt charIndex: Int) -> Bool
    {
        var longestEffectiveRange: NSRange = NSMakeRange(0, 0)
        if let textStorage = layoutManager.textStorage,
            let _ = textStorage.attribute(convertToNSAttributedStringKey(kFuriganaAttributeName), at: charIndex, longestEffectiveRange: &longestEffectiveRange, in: NSMakeRange(0, textStorage.length)) as? NSString
        {
            return charIndex == longestEffectiveRange.location
        }
        else
        {
            return true
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKey(_ input: String) -> NSAttributedString.Key {
	return NSAttributedString.Key(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
