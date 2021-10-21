import UIKit

class MainTabBarViewController: UITabBarController {
    
    
    required init(coder: NSCoder){
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let favoriteChannelsManager = FavoriteChannelsManager()
        attachFavoriteChannlesManager(favoriteChannelsManager)
        
    }
    
    private func attachFavoriteChannlesManager(_ manager: FavoriteChannelsManager){
        guard let controllers = self.viewControllers else {
            return
        }
        for controller in controllers{
            switch controller {
            case let allChannelsViewController as AllChannelsViewController:
                allChannelsViewController.favoriteChannelsManager = manager
            case let newsNavigationController as NewsNavigationController:
                newsNavigationController.favoriteChannelsManager = manager
            default:
                ()
            }
        }
    }


}

