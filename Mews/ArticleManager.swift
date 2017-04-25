import Foundation
import SwiftyJSON

open class ArticleManager {
    
    public typealias ArticlesLoadedClosure = ((Result<Array<Article>>) -> Void)
    public typealias ArticleLoadedClosure = ((Result<Article>) -> Void)
    
    open static let singleton = ArticleManager()
    
    open var articles: Dictionary<String, Article> = Dictionary()
    
    open func populateArticleDetail(_ id: String, completed: @escaping ArticleLoadedClosure) {
        guard let article = articles[id] else {
            completed(Result<Article>.failure(NSError(domain: "No such article found.", code: -1, userInfo: nil)))
            
            return
        }
        
        if article.main == nil {
            // Hard code for now, later we will build a real URL based on the article ID
            //
            let articleURL = getArticleURL(article.id)
            
            ScrapeArticleText.fetch(articleURL) { (result: Result<String>) -> Void in
                switch result {
                case .success(let string):
                    article.main = FuriganaTextParser.createFuriganaString(string)
                    
                    completed(Result.success(article))
                    
                case .failure(let error):
                    completed(Result.failure(error))
                }
            }
        }
        else {
            completed(Result.success(article))
        }
    }
    
    open func fetch(_ completed: @escaping ArticlesLoadedClosure) {
        var popularArticles: Array<Article> = Array<Article>()
        
        FetchJSON.fetch(getPopularArticlesURL()) { (result: Result<JSON>) -> Void in
            switch result {
            case .success(let json):
                for (_, articleListJson):(String, JSON) in json {
                    let articleKey = articleListJson["news_id"].stringValue
                    if self.articles[articleKey] == nil {
                        self.articles[articleKey] = self.createArticle(articleListJson, topStory: true)
                    }
                    
                    popularArticles.append(self.articles[articleKey]!)
                }
                
                popularArticles.sort(by: { (a, b) -> Bool in
                    return (a.topStoryPriority < b.topStoryPriority)
                })
        
                var allArticles: Array<Article> = Array<Article>()
                
                FetchJSON.fetch(self.getArticlesURL()) { (result: Result<JSON>) -> Void in
                    var counter = 0
                    
                    switch result {
                    case .success(let json):
                        for (_,articleGroupJson):(String, JSON) in json {
                            for (_, articleListJson):(String, JSON) in articleGroupJson {
                                for (_, articleJson):(String, JSON) in articleListJson {
                                    let articleKey = articleJson["news_id"].stringValue
                                    
                                    //if counter == 10 || counter == 50 {
                                    //    allArticles.append()
                                    //}
                                    
                                    // The article may have already been loaded
                                    //
                                    if self.articles[articleKey] == nil {
                                        self.articles[articleKey] = self.createArticle(articleJson, topStory: false)
                                    }
                                    
                                    if self.articles[articleKey]?.isTopStory != true {
                                        allArticles.append(self.articles[articleKey]!)
                                    
                                        counter += 1
                                    }
                                }
                            }
                        }
                        
                        allArticles.sort(by: { (a, b) -> Bool in
                            return (a.publicationDate?.isGreaterThanDate(b.publicationDate!))!
                        })
                        
                        // Placeholders for ads
                        //
                        popularArticles.append(Article(id: AppContext.singleton.adMarker, isTopStory: false))
                        
                        // Placeholders for more ads
                        //
                        allArticles.insert(Article(id: AppContext.singleton.adMarker, isTopStory: false), at: 10)
                        allArticles.insert(Article(id: AppContext.singleton.adMarker, isTopStory: false), at: 50)
                        
                        popularArticles.append(contentsOf: allArticles)
                        
                        completed(Result.success(popularArticles))
                        
                    case .failure(let error):
                        completed(Result.failure(error))
                    }
                }
                
            case .failure(let error):
                completed(Result.failure(error))
            }
        }
    }
    
    fileprivate init() {
    }
    
    fileprivate func getPopularArticlesURL() -> String {
        return "http://www3.nhk.or.jp/news/easy/top-list.json?_=1469436855539"
    }
    
    fileprivate func getArticlesURL() -> String {
        return "http://www3.nhk.or.jp/news/easy/news-list.json?_=1469436855540"
    }
    
    fileprivate func getArticleURL(_ id: String) -> String {
        return "http://www3.nhk.or.jp/news/easy/" + id + "/" + id + ".html"
    }
    
    fileprivate func createArticle(_ json: JSON, topStory: Bool) -> Article {
        let article = Article(id: json["news_id"].stringValue, isTopStory: topStory)
        
        let publicationDate = json["news_prearranged_time"].stringValue
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        article.publicationDate = dateFormatter.date(from: publicationDate)
        article.imageURL = json["news_web_image_uri"].stringValue
        
        
        if article.isTopStory {
            article.topStoryPriority = Int(json["top_priority_number"].stringValue)!
        }
        
        article.title = FuriganaTextParser.createFuriganaString(json["title_with_ruby"].stringValue)
        
        return article
    }

}
