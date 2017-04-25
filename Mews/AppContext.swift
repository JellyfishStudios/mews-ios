import Foundation

open class AppContext {
    open var verticalArticles: Bool = true
    open var rightToLeftArtices: Bool = true
    open var furiganaArticles: Bool = true
    open var adMarker: String = "XXX"
    open var detailAdMobAppBannerID: String = "ca-app-pub-6677464850109338/9218363803" //"ca-app-pub-3940256099942544/2934735716"
    open var listingsadMobAppBannerID: String = "ca-app-pub-6677464850109338/4972647403" // "ca-app-pub-3940256099942544/2934735716"
    
    fileprivate static let _singleton: AppContext = AppContext()
    
    open static var singleton : AppContext {
        get {
            return _singleton
        }
    }
    
    fileprivate init() {
    }
}
