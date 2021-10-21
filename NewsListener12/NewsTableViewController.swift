import UIKit

class NewsTableViewController: UITableViewController, UITableViewDataSourcePrefetching {
  
    var newsManager: NewsManager?
    private var footer = UIView()
    private var sendedToUpload = false
    private let imagePreLoader = ImagePrefetcher()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "newsCell")
        self.tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: "loadCell")
        self.refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Loading articles")
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.tableView.numberOfRows(inSection: 0) == 0 {
            self.tableView.refreshControl?.beginRefreshing()
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.refreshControl?.frame.size.height ?? 0) , animated: animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let manager = newsManager,
              self.tableView.numberOfRows(inSection: 0) == 0 else {
            return
        }
        
        manager.loadArticles {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (section > 0) {
            return isIndicatorAvailiable() ? 1 : 0
        }
        return newsManager?.articlesCount() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard indexPath.section == 0 else {
            return tableView.dequeueReusableCell(withIdentifier: "loadCell", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
        guard let articleCell = cell as? ArticleTableViewCell,
              let manager = newsManager,
              let article = manager.article(at: indexPath.row) else {return cell}
            
        
        articleCell.nameLabel.text = article.title
        articleCell.descriptionLabel.text = article.description
        articleCell.setupImage(url: article.urlToImage, id: article.id)
        return articleCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 1) ? 40.0 : 150.0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section > 0  {
            (cell as! LoadingTableViewCell).refreshControll.startAnimating()
        }
    }
  
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isIndicatorAvailiable(),
              !sendedToUpload,
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) else {
            return
        }
        let y = scrollView.contentOffset.y
        let height = scrollView.frame.size.height - scrollView.safeAreaInsets.bottom
        let cellY = cell.frame.origin.y
        let cellHeight = cell.frame.size.height
        if (cellY + cellHeight <= y + height){
            print("Reload")
            loadMoreData()
        }
    }

// MARK: - Table View data source prefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let manager = newsManager else {
            return
        }
        DispatchQueue.global(qos: .utility).async {
            let idArray: [(String, URL)] = indexPaths.compactMap { indexPath in
                guard let unwrapedId = manager.article(at: indexPath.row)?.id,
                      let unwrappedUrl = manager.article(at: indexPath.row)?.urlToImage else{
                    return nil
                }
                return (unwrapedId, unwrappedUrl)
            }
            self.imagePreLoader.prefetchImages(forIdArray:idArray)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        guard let manager = newsManager else {
            return
        }
        DispatchQueue.global(qos: .utility).async {
            let idArray: [String] = indexPaths.compactMap { indexPath in
                return manager.article(at: indexPath.row)?.id
            }
            self.imagePreLoader.cancellPrefetching(forIdArray: idArray)
        }
    }
    
    
    @objc func refresh(_ sender:AnyObject) {
        guard let manager = newsManager else {
            return
        }
        manager.loadArticles(needsReload: true){
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func loadMoreData(){
        sendedToUpload = true
        guard let manager = newsManager,
              !manager.isLoading() else {
            sendedToUpload = false
            return
        }
        
       manager.loadMoreArticlesPages {
            
            //            let indexPaths = (oldCount...manager.articlesCount()-1)
            //                .map{ index in IndexPath(row: index, section: 0)}
            
            DispatchQueue.main.async {
                UIView.performWithoutAnimation {
                    let contentOffset = self.tableView.contentOffset
                    self.tableView.reloadData()
                    self.tableView.setContentOffset(contentOffset, animated: false)
                }
                self.sendedToUpload = false
            }
        }
    }
    
    private func isIndicatorAvailiable() -> Bool {
        guard let manager = newsManager,
              manager.articlesCount() != 0,
              !manager.loadingLimitReached else {
            return false
        }
        return true
    }
}



