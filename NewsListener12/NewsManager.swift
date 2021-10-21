import Foundation
import UIKit.UIImage

class NewsManager: NSObject{
    
    public var favoriteChannelsManager: FavoriteChannelsManager?
    
    private var articlesArray: [Article] = []
    private var articlesLoadingTask: URLSessionTask?
    private var pagesLoaded = 0
    private var date = ""
    private var sources = ""
    
    private let articlesFileName = "Articles.json"
    private(set) public var loadingLimitReached = false
    private var needsReload = false
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(appResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        loadArticlesFromFile()
    }
    
//  MARK: - Articles Handling
    func articlesCount() -> Int{
        return articlesArray.count
    }
    
    func article(at index: Int) -> Article? {
        return articlesArray[index]
    }
    
//  MARK: - Load articles data
    func loadArticles (needsReload: Bool = false, completion completionHandler: @escaping()->Void){
        date = ISO8601DateFormatter().string(from: Date())
        self.needsReload = needsReload
        startTask(additionalHandler: completionHandler)
    }
    
    func loadMoreArticlesPages(_ controllerCompletionHandler: @escaping()->Void) {
        DispatchQueue.global(qos: .userInitiated).async{
            guard !self.loadingLimitReached  else {
                controllerCompletionHandler()
                return
            }
            self.startTask(additionalHandler: controllerCompletionHandler)
        }
    }
    
    func isLoading() -> Bool {
        return (articlesLoadingTask?.state == .running) 
    }
    
    private func constructRequestParameters()->[String:String]{
        var components = [String:String]()
        if (pagesLoaded == 0 || needsReload){
            sources = currentSources()
        }
        components["sources"] = sources
        components["to"] = date
        if pagesLoaded > 0 && !needsReload {
            components["page"] = "\(pagesLoaded+1)"
        }
        return components
    }
    
    private func constructCompletionHandler(_ additionalHandler: @escaping()->Void) -> ([Article]?)->Void{
        return {(articles) in
            guard let articlesUnwrapped = articles else {
                if (self.pagesLoaded > 0) {
                    self.loadingLimitReached = true
                }
                additionalHandler()
                return
            }
            if self.needsReload {
                self.clear()
            }
            self.articlesArray.append(contentsOf: articlesUnwrapped)
            self.pagesLoaded += 1
            additionalHandler()
        }
    }
    
    private func startTask(additionalHandler: @escaping() -> Swift.Void){
        guard articlesLoadingTask?.state != .running,
              !loadingLimitReached || needsReload else {
            needsReload = false
            additionalHandler()
            return
        }
        articlesLoadingTask =
            NewsAPIProvider.newsLoadingTask(withParameters: constructRequestParameters(), completionHandler: constructCompletionHandler(additionalHandler))
        articlesLoadingTask?.resume()
    }
// MARK: - Utilities
    func currentSources() -> String{
        return favoriteChannelsManager?.sourcesIdString() ?? ""
    }
    
    private func clear(){
        LocalFileManager.instance.deleteAllImages()
        LocalFileManager.instance.deleteFile(name: "Articles.json")
        self.articlesArray.removeAll()
        self.pagesLoaded = 0
        self.loadingLimitReached = false
        self.needsReload = false
    }
// MARK: - UIapplication notification handler
    @objc func appResignActive(){
        self.saveArtilces()
    }
// MARK: - File Save/Load
    private func loadArticlesFromFile(){
        LocalFileManager.instance.asyncGetDataFromFile(name: articlesFileName) { data in
            guard let articlesData = data,
                  let articles = try? JSONDecoder().decode([Article].self, from: articlesData)
            else {
                return
            }
            self.articlesArray.append(contentsOf: articles)
            self.loadingLimitReached = true
        }
    }
    
    private func saveArtilces(){
        guard let data = try? JSONEncoder().encode(articlesArray) else {
            return
        }
        LocalFileManager.instance.saveToFile(data: data, name: articlesFileName)
    }
}
