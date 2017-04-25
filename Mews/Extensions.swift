import Foundation
import UIKit

public enum Result<T> {
    case success(T)
    case failure(Error)
}

private let kCharLength = 1

public extension NSString
{
    
    
    public func substringAtIndex(_ index: Int) -> String {
        return substring(with: NSMakeRange(index, kCharLength))
    }
    
    public func filteredString(_ predicateBlock: (NSString) -> Bool) -> NSString {
        var result = ""
        
        enumerateCharacters { (index, charString) -> Void in
            if predicateBlock(charString)
            {
                result += charString as String
            }
        }
        
        return result as NSString
    }
    
    public func enumerateCharacters(_ enumeration: (Int, NSString) -> Void) {
        for i in 0..<length
        {
            enumeration(i, substringAtIndex(i) as NSString)
        }
    }
}

public extension String {
    func find(_ pattern: String) -> NSTextCheckingResult? {
        
        do {
            let result = try NSRegularExpression(pattern: pattern, options: [])
            
            return result.firstMatch(
                in: self,
                options: [],
                range: NSMakeRange(0, self.utf16.count))
        }
        catch {
            return nil
        }
    }
    
    func replace(_ pattern: String, template: String) -> String {
        do {
            let result = try NSRegularExpression(pattern: pattern, options: [])
            
            return result.stringByReplacingMatches(
                in: self,
                options: [],
                range: NSMakeRange(0, self.utf16.count),
                withTemplate: template)
        }
        catch {
            return self
        }
    }
}

extension Date {
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(_ daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(_ hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

public extension UIImageView {
    func downloadedFrom(_ link: String, identifier: AnyObject? = nil, completion: ((Result<AnyObject>) -> Void)? = nil) {
        guard let url = URL(string: link) else {
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse , httpURLResponse.statusCode == 200,
                let data = data , error == nil,
                let image = UIImage(data: data) else {
            return
            }
            
            DispatchQueue.main.async(execute: {
                self.image = image
                
                if completion != nil {
                    completion!(Result.success(identifier!))
                }
            })
        }) .resume()
    }
}
