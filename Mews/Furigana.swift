//
//  StringRubyAnnotationExt.swift
//
//  Created by adunne on 7/22/16.
//  Copyright © 2016 Adrian Dunne. All rights reserved.
//
import Foundation

open class FuriganaText
{
    open var furigana: [Furigana ]
    open var original: String
    
    public init(original: String, furigana: [Furigana ])
    {
        self.original = original
        self.furigana = furigana
    }
}

public struct Furigana
{
    public let text: String
    public let original: String
    public let range: NSRange
    
    public let UUID: Foundation.UUID = Foundation.UUID()
    
    public init(text: String, original: String, range: NSRange)
    {
        self.text = text
        self.original = original
        self.range = range
    }
}

public var furiganaEnabled = true

public let kFuriganaAttributeName = "com.anogaijin.furigana"

private let kFuriganaRepresentationFormatter = "|"

public func FuriganaStringRepresentation(_ furigana: Furigana) -> NSString
{
    let values: NSArray = [
        furigana.text,
        furigana.UUID.uuidString,
        furigana.original
    ]
    return values.componentsJoined(by: kFuriganaRepresentationFormatter) as NSString
}

public func FuriganaTextFromStringRepresentation(_ string: NSString) -> NSString?
{
    return string.components(separatedBy: kFuriganaRepresentationFormatter).first as NSString?
}

public func FuriganaOriginalTextFromStringrepresentation(_ string: NSString) -> NSString?
{
    return string.components(separatedBy: kFuriganaRepresentationFormatter).last as NSString?
}
