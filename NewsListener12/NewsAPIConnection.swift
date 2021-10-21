import Foundation



class NewsAPIProvider: NSObject {
    
    private static let urlString = "https://newsapi.org/v2/"
    private static let apiValue = "ea7ae63db2f9498a832f78738197fdd6"

    enum requestEndpoint:String{
        case everything = "/v2/everything"
        case sources = "/v2/top-headlines/sources"
    }
    
    
    static func testConnection (){
        var request = URLRequest(url: sourcesRequestComponents().url!)
        request.setValue(apiValue, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            NSLog("%d",statusCode ?? 0)
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                as! [String : AnyObject]
                NSLog("data %@",jsonData)
            }catch let error as NSError{
                NSLog("error %@",error)
            }
        }
        task.resume()        
    }
    
    ///Creates URLSession task for loading all availiable channels from NewsAPI.org
 
    static func allChannelsTask(completionHandler cHandler: @escaping([Channel]?)->Void) -> URLSessionTask?{
        let requestComponents = sourcesRequestComponents()
        guard let request = requestFromComponents(requestComponents) else {
            cHandler (nil)
            return nil
        }
        return URLSession.shared.dataTask(with: request){(data, response, error) in
            cHandler(Channel.responceDataToChannelsArray(data))
        }
    }
    
    ///Create URLSession tast for loading news articles from NewsAPI.org
    
    static func newsLoadingTask(withParameters parameters: [String:String], completionHandler cHandler:@escaping([Article]?)->Void)-> URLSessionTask?{
        let requestComponents = componentsForEndpoint(.everything, parameters: parameters)
        guard let request = requestFromComponents(requestComponents) else {
            cHandler (nil)
            return nil
        }
        return URLSession.shared.dataTask(with: request){(data, response, error) in
            cHandler(Article.responceDataToArticlesArray(data))
        }
    }
    
  /// Generate URLComponents for sources (AllChannels requests)
   
    private static func sourcesRequestComponents()-> URLComponents{
        return componentsForEndpoint(.sources, parameters: [:])
    }
    
    /// Creates URLComponents for requests of any type from NewsAPI.org
    
    private static func componentsForEndpoint(_ endpoint : requestEndpoint, parameters : [String:String]) -> URLComponents {
        var requestComponents: URLComponents
        #if DEBUG
        var path = ""
        switch endpoint {
        case .sources :
            path = "channels"
        case .everything:
            path = "ArticleResponse" + (parameters["page"] ?? "")
        }
        let resourceURL = Bundle.main.url(forResource: path, withExtension: "json")!
            requestComponents = URLComponents(url: resourceURL, resolvingAgainstBaseURL: true)!
        #else
            requestComponents = URLComponents(string: urlString)!
            requestComponents.path = endpoint.rawValue
            if (!parameters.isEmpty){
                requestComponents.queryItems = parameters.map{(key,value) in URLQueryItem(name: key, value: value)
                }
            }
        #endif
        return requestComponents
    }
    
    /// Generates URLRequest from components and adding APIKey for all  NewsAPI.org http requests
    
    private static func requestFromComponents(_ componets: URLComponents)->URLRequest?{
        guard let url = componets.url else {return nil}
        var request = URLRequest(url: url)
        request.setValue(apiValue, forHTTPHeaderField: "Authorization")
        return request
    }

}


