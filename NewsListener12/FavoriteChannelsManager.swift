import Foundation
import UIKit.UIApplication


class FavoriteChannelsManager{
    
    private var channelsArray: [Channel] = []

    private let channelsFileName = "Channels.json"
    var loading = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
// MARK: - Channels handling
    func channelsCount() -> Int {
        return channelsArray.count
    }
    
    func channelAtIndex(index: Int) -> Channel {
        return channelsArray[index]
    }
    

//  MARK: - Adding/Removing from favorites
    func addChannelToFavorites(atIndex index: Int){
        channelsArray[index].favored = true
    }
    
    func removeChannelFromFavorites(atIndex index: Int){
        channelsArray[index].favored = false
    }
    
    func removeFavorite(name removedChannelName: String){
        guard let index = channelsArray.firstIndex(where: { channel in
            channel.name == removedChannelName
        }) else {
            return
        }
        channelsArray[index].favored = false
        NotificationCenter.default.post(name: .didRemoveFavoriteChannel, object: nil, userInfo: ["index":index])
    }
    
//  MARK: - Favorites handle
    
    private func generateFavorites() -> [String] {
        return channelsArray.compactMap { channel in
            return (channel.favored) ?  channel.name : nil
        }
    }
    
    private func registerFavorites(_ favorites: [String]){
        for index in 0..<channelsArray.count{
            if favorites.contains(channelsArray[index].name){
                channelsArray[index].favored = true
            }
        }
    }
    
    func  favoriteAtIndex(_ index: Int) -> String {
        return generateFavorites()[index]
    }
    
    func favoritesCount() -> Int {
        return generateFavorites().count
    }
    
    func sourcesIdString() -> String{
        var sources = channelsArray.reduce("") { result, channel in
            if channel.favored {
                return result + "\(channel.id),"
            }
            return result
        }
        if (sources.last == ","){
            sources.removeLast()
        }
        return sources
    }
    
//  MARK: - Loading
    func initialLoad(completion: @escaping() -> Swift.Void) {
        self.loadChannelsFromFile(completion: completion)
    }
    
    func loadChannels(reload: Bool = false, completion: @escaping() -> Swift.Void){
        let task = NewsAPIProvider.allChannelsTask { channels in
            guard let channelsUnwraped = channels else{
                completion()
                return
            }
            if(reload){
                self.removeChannelsFile()
                let favorites = self.generateFavorites()
                self.channelsArray.removeAll()
                self.channelsArray.append(contentsOf: channelsUnwraped)
                self.registerFavorites(favorites)
            } else {
                self.channelsArray.append(contentsOf: channelsUnwraped)
            }
            completion()
        }
        task?.resume()
    }

// MARK: - File storage working
    
    private func loadChannelsFromFile(completion: @escaping() -> Swift.Void){
        LocalFileManager.instance.asyncGetDataFromFile(name: channelsFileName) { data in
            guard let channelsData = data,
                  let channels = try? JSONDecoder().decode([Channel].self, from: channelsData)
            else {
                self.loadChannels(completion: completion)
                return
            }
            self.channelsArray.append(contentsOf: channels)
            completion()
        }
    }
    
    private func saveChannelsToFile(){
        guard let data = try? JSONEncoder().encode(channelsArray) else {
            return
        }
        LocalFileManager.instance.saveToFile(data: data, name: channelsFileName)
    }
    
    private func removeChannelsFile(){
        LocalFileManager.instance.deleteFile(name: channelsFileName)
    }
    
    @objc func appResignActive(){
        self.saveChannelsToFile()
    }
}

