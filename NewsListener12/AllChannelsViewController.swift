import UIKit

class AllChannelsViewController: UITableViewController{
    
    private let alert = UIAlertController(title: "Too many favorite channels", message: "You don't have more than 20 favorite channels. Delete another favorite channel to add this one", preferredStyle: .alert)
    
    private let channelsFileName = "Channels.json"
    
    var favoriteChannelsManager: FavoriteChannelsManager?    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Loading channels")
        
        guard let manager = favoriteChannelsManager else {
            return
        }
        self.refreshControl?.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0, y: self.refreshControl?.frame.size.height
                                                    ?? 0), animated: false)
        manager.initialLoad {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector (didRemoveFavoriteChannel), name:.didRemoveFavoriteChannel, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.removeObserver(self, name: .didRemoveFavoriteChannel, object: nil)
    }
   
    
//  MARK: - Table View data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteChannelsManager?.channelsCount() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)
        guard let channelCell = cell as? ChannelTableViewCell,
              let manager = favoriteChannelsManager else {
            return cell
        }
        let channel = manager.channelAtIndex(index: indexPath.row)
        channelCell.nameLabel.text = channel.name
        channelCell.descriptionLabel.text = channel.description
        channelCell.favored = channel.favored
        return channelCell
    }
    
//  MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard  let manager = favoriteChannelsManager,
               let channelCell = tableView.cellForRow(at: indexPath) as? ChannelTableViewCell else {
            return
        }
        if manager.favoritesCount() == 20 && channelCell.favored {
            self.present(alert, animated: true, completion: nil)
            channelCell.favored = false
            return
        }
        if channelCell.favored {
            manager.addChannelToFavorites(atIndex: indexPath.row)
        } else {
            manager.removeChannelFromFavorites(atIndex: indexPath.row)
        }
    }
// MARK: - Refresh handle
    
//    private func startLoadingAllChannelsData(reload: Bool = false){
//        let task = NewsAPIProvider.allChannelsTask { channels in
//            guard let channelsUnwraped = channels else{
//                DispatchQueue.main.async {
//                    self.refreshControl?.endRefreshing()
//                }
//                self.refreshControl?.endRefreshing()
//                return
//            }
//            if(reload){
//                self.channelsArray.removeAll()
//            }
//            self.channelsArray.append(contentsOf: channelsUnwraped)
//            DispatchQueue.main.async {
//                self.refreshControl?.endRefreshing()
//                self.tableView.reloadData()
//            }
//        }
//        task?.resume()
//    }
    
    @objc private func refresh(_ sender: UIRefreshControl){
        guard let manager = favoriteChannelsManager else {
            return
        }
        manager.loadChannels(reload: true) {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
//  MARK: - Notifications observers

    @objc private func didRemoveFavoriteChannel(_ notification: Notification){
        guard let removedChannelIndex = notification.userInfo?["index"] as? Int else {
            NSLog("\(self) failed get channel index from notification \(notification)")
            return
        }
        guard let channelCell = self.tableView.cellForRow(at: IndexPath(row: removedChannelIndex, section: 0)) as? ChannelTableViewCell else{
            return
        }
        channelCell.favored = false
    }    
}
