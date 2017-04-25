import Foundation

open class Article {
    open var id: String
    open var isTopStory: Bool
    open var topStoryPriority: Int
    
    open var imageURL: String?
    
    open var publicationDate: Date?
    
    open var title: FuriganaText?
    open var main: FuriganaText?
    
    public init(id: String, isTopStory: Bool) {
        self.id = id
        self.isTopStory = isTopStory
        self.topStoryPriority = 0
    }
}
