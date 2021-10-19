import Foundation

struct Channel: Codable, Equatable {
    
    var description: String
    var name: String
    var id: String
    var favored: Bool = false
    
    var category: String?
    var country: String?
    var language: String?
    var url: URL?
    
    enum ArticleCodingKeys: String, CodingKey {
        case name
        case description
        case id
        case favored
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        id = try container.decode(String.self, forKey: .id)
        favored = (try? container.decode(Bool.self, forKey: .favored)) ?? false
    }
    
}

extension Channel {
    struct AllChannelsResponse: Decodable {
        var status: String
        var sources: [Channel]?
    
        var code: String?
    }
    
    static func responceDataToChannelsArray (_ data : Data?) -> [Channel]?{
        guard let data = data,
              let jsonData = try? JSONDecoder().decode(AllChannelsResponse.self, from: data)
              else{
            NSLog("Error decoding channels request response")
            return nil
        }
        guard jsonData.status == "ok", let channels = jsonData.sources else{
            NSLog("Error loading all channels, status \(jsonData.code ?? jsonData.status)")
            return nil
        }
        return channels
    }
}
