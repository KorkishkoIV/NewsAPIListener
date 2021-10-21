import Foundation
import UIKit

class FavoriteChannelsTableViewController: UITableViewController{
    @IBOutlet weak var newsBarButton: UIBarButtonItem!
    var favoriteChannelsManager: FavoriteChannelsManager?
    let newsManager: NewsManager = NewsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        self.newsBarButton.isEnabled = (self.favoriteChannelsManager?.favoritesCount() ?? 0 > 0)
    }
    
//  MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteChannelsManager?.favoritesCount() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteChannelTableViewCell", for: indexPath)
        guard let favoriteChannelCell = cell as? FavoriteChannelTableViewCell,
              let favoriteChannelName = self.favoriteChannelsManager?.favoriteAtIndex(indexPath.row)
            else{
                return cell
        }
        favoriteChannelCell.nameLabel.text = favoriteChannelName
        return cell
    }

//  MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove from favorites"){[unowned self](action,view,handler) in
            guard let manager = self.favoriteChannelsManager else{
                handler(false)
                return
            }            
            manager.removeFavorite(name: manager.favoriteAtIndex(indexPath.row))
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.newsBarButton.isEnabled = manager.favoritesCount() > 0
            handler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

//  MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showNews",
              let destination = segue.destination as? NewsTableViewController,
              let manager = favoriteChannelsManager  else {return}
        newsManager.favoriteChannelsManager = manager
        destination.newsManager = newsManager
    }
    
}
