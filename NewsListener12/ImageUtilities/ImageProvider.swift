import Foundation
import UIKit.UIImage

protocol ImageProvider {
    func asyncGetImage(id: String, completion: @escaping (UIImage?)->Swift.Void)
    func setImage(id: String, image: UIImage)
    func containsImage(forId id: String) -> Bool
}

