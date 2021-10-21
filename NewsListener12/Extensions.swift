import Foundation
import UIKit

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Notification.Name{
    static let didRemoveFavoriteChannel = Notification.Name("didRemoveFavoriteChannel")
}

extension UIImage{
    static func downsample(imageAt imageURL: URL,
                    to pointSize: CGSize,
                    scale: CGFloat = UIScreen.main.scale) -> UIImage? {

        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
            return nil
        }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }        
        return UIImage(cgImage: downsampledImage)
    }    
}

extension UITextField {
    func setLeftImage (_ image: UIImage?){
        self.leftViewMode = .always
        let iconImageView = UIImageView(frame: CGRect(x: self.frame.size.height/4, y: self.frame.size.height/4, width: self.frame.size.height/2, height: self.frame.size.height/2))
        iconImageView.image = image
        iconImageView.tintColor = .lightGray
        iconImageView.contentMode = .scaleAspectFit
        
        let iconContainerView: UIView = UIView(frame:
                                                CGRect(x: 0, y: 0, width: self.frame.size.height, height: self.frame.size.height))
        iconContainerView.addSubview(iconImageView)
        
        self.leftView = iconContainerView
    }
}


