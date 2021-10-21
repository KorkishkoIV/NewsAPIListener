import Foundation
import UIKit

class NewsNavigationController: UINavigationController{
    
    var favoriteChannelsManager: FavoriteChannelsManager? {
        didSet{
            if let favoriteChannelsTableViewController = self.getFavoriteChannelsViewController(){
                favoriteChannelsTableViewController.favoriteChannelsManager = favoriteChannelsManager
            }
        }
        
    }    
    
    private func getFavoriteChannelsViewController()->FavoriteChannelsTableViewController?{
        for viewController in self.viewControllers{
            switch viewController {
            case let favoriteChannelsViewController as FavoriteChannelsTableViewController:
                return favoriteChannelsViewController
            default:
                ()
            }
        }
        return nil
    }
}
