//
// Handle multiple data sources for test purposes
//
//

import Foundation
import UIKit
import SwiftyJSON

open class FetchJSON {
    
    public typealias CompletionClosure = ((Result<JSON>) -> Void)
    
    open class func fetch(_ endpoint: String, completion: @escaping CompletionClosure) {
        if let url = URL(string: endpoint) {
            if UIApplication.shared.canOpenURL(url) {
                fromURL(url, completion: completion)
            }
            else {
                fromBundledFile(endpoint, completion: completion)
            }
        }
    }
    
    fileprivate static func fromBundledFile(_ fileName: String, completion: @escaping CompletionClosure) {
        // Load the file asynchronously in a background thread
        //
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            let filePath = Bundle.main.path(forResource: fileName, ofType:"json")
            let data = try! Data(contentsOf: URL(fileURLWithPath: filePath!), options: NSData.ReadingOptions.uncached)
            
            buildJSONFromData(data, completion: completion)
        })
    }
    
    fileprivate static func fromURL(_ url: URL, completion: @escaping CompletionClosure) {
        // Load the file asynchronously in a background thread
        //
        let loadDataTask = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
            if let error = error {
                DispatchQueue.main.async(execute: {
                    completion(Result.failure(error))
                })
            }
            else {
                buildJSONFromData(data!, completion: completion)
            }
        })
        
        loadDataTask.resume()
    }
    
    fileprivate static func buildJSONFromData(_ data: Data, completion: @escaping CompletionClosure) {
        let swiftyJSON = JSON(data: data)
        
        DispatchQueue.main.async(execute: {
            completion(Result.success(swiftyJSON))
        })
    }
}
