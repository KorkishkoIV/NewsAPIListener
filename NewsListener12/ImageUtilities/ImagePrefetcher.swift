//import Foundation
import UIKit.UIImage

class ImagePrefetcher {
    
    private var loadingTasks = [String: DispatchWorkItem]()
    private let provider: ImageProvider
    static private let prefetchingQueue = DispatchQueue.init(label: "NewsListenerImagePrefetching", qos: .utility)
    private let size = CGSize(width: UIScreen.main.bounds.width, height: 150)
    
    static let insatnce = ImagePrefetcher()
    
    init(provider: ImageProvider = LocalFileManager.instance) {
        self.provider = provider
    }
    
    public func prefetchImages(forIdArray idArray: [(String, URL)]){
        for (id, url) in idArray {
            guard !loadingTasks.keys.contains(id),
                  !provider.containsImage(forId: id) else {
                continue
            }
            let loadingBlock = DispatchWorkItem {
                guard let loadedImage = UIImage.downsample(imageAt: url, to: self.size) else {
                    return
                }
                self.provider.setImage(id: id, image: loadedImage)
                self.loadingTasks.removeValue(forKey: id)
            }
            ImagePrefetcher.prefetchingQueue.sync(execute: loadingBlock)
        }
    }
    
    public func cancellPrefetching(forIdArray idArray: [String]){
        for id in idArray {
            loadingTasks[id]?.cancel()
            loadingTasks.removeValue(forKey: id)
        }
    }
    
}
