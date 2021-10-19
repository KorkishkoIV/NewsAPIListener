import Foundation
import UIKit.UIImage

// MARK: - Article

struct Article: Codable, Equatable {
    struct ArticleSource: Codable, Equatable {
        var id: String?
        var name: String
        static func == (lhs: ArticleSource, rhs: ArticleSource) -> Bool {
            return lhs.name == rhs.name
        }
        
    }
    var id: String
    var source: ArticleSource
    var title: String
    var description: String?
    var urlToImage: URL?
    var publishedAt: String
    
    var author: String?
    var url: URL?
    var content: String?
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.title == rhs.title
            && lhs.description == rhs.description
            && lhs.publishedAt == rhs.publishedAt
            && lhs.source == rhs.source
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case source
        case title
        case description
        case urlToImage
        case publishedAt
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.decode(ArticleSource.self, forKey: .source)
        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        description = try? container.decode(String.self, forKey: .description)
        urlToImage = try? container.decode(URL.self, forKey: .urlToImage)
        publishedAt = try container.decode(String.self, forKey: .publishedAt)
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(urlToImage, forKey: .urlToImage)
        try container.encode(publishedAt, forKey: .publishedAt)
        try container.encode(id, forKey: .id)
    }
}

// MARK: - accessing article info from responce Data
extension Article {
    struct ArticlesResponce: Decodable {
        var status: String
        var totalResults: Int?
        var articles:[Article]?
        
        var code: String?
    }
    
    
    
    static func responceDataToArticlesArray (_ data : Data?) -> [Article]?{
        guard let data = data,
              let jsonData = try? JSONDecoder().decode(ArticlesResponce.self, from: data)
              else{
            NSLog("Error decoding responce for article request")
            return nil
        }
        guard jsonData.status == "ok", let articles = jsonData.articles else{
            NSLog("Error loading for articles request, code: \(jsonData.code ?? jsonData.status)")
            return nil
        }
        return articles
    }
}
