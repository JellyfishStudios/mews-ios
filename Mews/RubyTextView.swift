//
//  RubyTextView.swift
//  Mews
//
//  Created by adunne on 7/13/16.
//  Copyright © 2016 Adrian Dunne. All rights reserved.
//

import UIKit


open class RubyTextView: UIView {
    open var attributedString: NSAttributedString?
    open var verticalText: Bool = true
    
    open var constrainX: Bool = true
    open var constrainY: Bool = true
    
    fileprivate var ctFrame: CTFrame?
    fileprivate var rtlXOffset: CGFloat = 0.0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard ctFrame != nil else {
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: rtlXOffset, y: self.bounds.size.height)
        context!.textMatrix = CGAffineTransform.identity
        context?.scaleBy(x: 1.0, y: -1.0)
        
        CTFrameDraw(ctFrame!, context!)
    }
       
    open func setup() {
        guard attributedString != nil else {
            return
        }
        
        if verticalText {
            rtlXOffset = -10.0
        }
        
        let rtlWidthOffset = rtlXOffset * -1
        
        let boundsRect = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        
        var fitRange = CFRangeMake(0, 0)
        
        var frameProgressonAttributeValue: Int = 0;
        if verticalText {
            frameProgressonAttributeValue = 3
        }
        
        let layoutDic = NSDictionary(dictionary: [
            kCTFrameProgressionAttributeName: frameProgressonAttributeValue])
        
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString!)
        
        
        var constraintX = boundsRect.width
        if !constrainX {
            constraintX = 20000
        }
        
        var constraintY = boundsRect.height
        if !constrainY {
            constraintY = 20000
        }
        
        let rect = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), layoutDic, CGSize(width: constraintX, height: constraintY), &fitRange)
        
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0.0, y: 0.0, width: rect.width + rtlWidthOffset, height: rect.height))
        
        ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, layoutDic)
        
        self.frame = CGRect(x: 0, y: 0, width: rect.width + rtlWidthOffset, height: rect.height)
    }
}
