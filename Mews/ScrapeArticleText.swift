import Foundation
import UIKit

open class ScrapeArticleText {
    public typealias CompletionClosure = (Result<String>) -> Void
    
    fileprivate static var cache: Dictionary<String, String> = Dictionary()
    
    open class func fetch(_ endpoint: String, completion: @escaping CompletionClosure) {
        if let articleText = cache[endpoint] {
            completion(Result.success(articleText))
        }
        
        if let url = URL(string: endpoint) {
            if UIApplication.shared.canOpenURL(url) {
                fromURL(url, completion: completion)
            }
            else {
                fromBundledFile(endpoint, completion: completion)
            }
        }
    }

    fileprivate class func fromBundledFile(_ fileName: String, completion: @escaping CompletionClosure) {
        // Load the file asynchronously ona  background thread
        //
        DispatchQueue.main.async(execute: {
            let filePath = Bundle.main.path(forResource: fileName, ofType:"html")
            let data = try! Data(contentsOf: URL(fileURLWithPath: filePath!), options: NSData.ReadingOptions.uncached)
            
            parse(fileName, data: data, completion: completion)
        })
    }

    fileprivate class func fromURL(_ url: URL, completion: @escaping CompletionClosure) {
        // Load the file asynchronously on a background thread
        //
        let loadDataTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
            if let error = error {
                DispatchQueue.main.async(execute: {
                    completion(Result.failure(error))
                })
            }
            
            parse(url.absoluteString, data: data!, completion: completion)
        }) 
        
        loadDataTask.resume()
    }
    
    fileprivate static func parse(_ key: String, data: Data, completion: @escaping CompletionClosure) {
        let articleHTML: String = String(describing: NSString(data: data, encoding:String.Encoding.utf8.rawValue))
        
        // Step 1:
        //          Take everything between <div id="newsarticle"> and </div>
        //
        if let result = articleHTML.find("<div id=\"newsarticle\">([\\s\\S]*?)</div>") {
            var articleText = (articleHTML as NSString).substring(with: result.rangeAt(1))
            
            // Step 2:
            //          Replace all </p> with line breaks
            articleText = articleText.replace("</p>", template: "\\\n")
            
            // Step 3:
            //          Strip all other HTML tags (except than the ruby tags)
            articleText = articleText.replace("</?(?!(?:rt|ruby)\\b)[a-z](?:[^>\"']|\"[^\"]*\"|'[^']*')*>", template: "")
            
            // Step 4:
            //          Clean-up line breaks (there may be two many at this point but assume a max of two for now)
            articleText = articleText.replace("\n+", template: "\n")
            
            // Step 5: 
            //          Finally, we trim
            articleText = articleText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            // Cache it!
            //
            cache[key] = articleText

            DispatchQueue.main.async(execute: {
                completion(Result.success(articleText))
            })

        }
        else {
            DispatchQueue.main.async(execute: {
                completion(Result.failure(NSError(domain: "Could not find the article's main text in NHK's HTML response.", code: -1, userInfo: nil)))
            })
        }
    }
}
