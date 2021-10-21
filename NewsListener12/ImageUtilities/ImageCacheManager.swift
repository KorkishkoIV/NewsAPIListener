import Foundation
import UIKit.UIImage

class ImageCacheManager: ImageProvider {
    
    static let instance = ImageCacheManager()
    private init() {}
    
    var imageCache: NSCache<NSString,UIImage> =  {
        var cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 Mb
        return cache
    }()
    
    func asyncGetImage(id: String, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            completion(self.imageCache.object(forKey: id as NSString))
        }
    }
    
    func setImage(id: String, image: UIImage) {
        imageCache.setObject(image, forKey: id as NSString)
    }
    
    func containsImage(forId id: String) -> Bool {
        return imageCache.object(forKey: id as NSString) != nil
    }
    
    func dropCache(){
        imageCache.removeAllObjects()
    }
}
