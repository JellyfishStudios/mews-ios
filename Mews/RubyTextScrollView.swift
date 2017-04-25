import Foundation
import CoreText
import UIKit

public class RubyTextScrollView : UIScrollView {
    private var attributedString: NSAttributedString?
    
    
    public func addText(text: NSAttributedString) {
        attributedString = text
    }
}
