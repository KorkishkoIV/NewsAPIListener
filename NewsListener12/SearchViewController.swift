import Foundation
import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var resultsTableView: UITableView!
    
    private let emptyLabel = UILabel()
    private var refreshActivity = UIActivityIndicatorView()
    private var resultArticles = [Article]()
    private var loadingTask: URLSessionTask?
    private var imagePreLoader = ImagePrefetcher(provider: ImageCacheManager.instance)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "newsCell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 13.0, *) {
            searchTextField.setLeftImage(UIImage(systemName: "magnifyingglass"))
        } else {
            searchTextField.setLeftImage(UIImage(named: "Glass"))
        }
        configureTableBackground()
    }
       
    enum TableState {
        case noResult
        case presentingResult
        case loadingResult
    }
    
    private var tableState: TableState = .noResult {
        didSet {
            switch  tableState {
            case .noResult:
                self.refreshActivity.stopAnimating()
                self.refreshActivity.isHidden = true
                self.emptyLabel.isHidden = false
            case .presentingResult:
                self.refreshActivity.stopAnimating()
                self.refreshActivity.isHidden = true
                self.emptyLabel.isHidden = true
            case .loadingResult:
                self.refreshActivity.isHidden = false
                self.refreshActivity.startAnimating()
                self.emptyLabel.isHidden = true
            }
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
        guard let articleCell = cell as? ArticleTableViewCell  else {
            return cell
        }
        let article = resultArticles[indexPath.row]
        articleCell.nameLabel.text = article.title
        articleCell.descriptionLabel.text = article.description
        articleCell.setupImage(url: article.urlToImage, id: article.id, method: .cache)
        return articleCell
    }
    
    // MARK: - TableView Data Source Preferetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        DispatchQueue.global(qos: .utility).async {
            let idArray: [(String, URL)] = indexPaths.compactMap { indexPath in
                let unwrapedId = self.resultArticles[indexPath.row].id
                guard let unwrappedUrl = self.resultArticles[indexPath.row].urlToImage else{
                    return nil
                }
                return (unwrapedId, unwrappedUrl)
            }
            self.imagePreLoader.prefetchImages(forIdArray:idArray)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        DispatchQueue.global(qos: .utility).async {
            let idArray: [String] = indexPaths.compactMap { indexPath in
                return self.resultArticles[indexPath.row].id
            }
            self.imagePreLoader.cancellPrefetching(forIdArray: idArray)
        }
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text{
            startSearch(text)
        }
        return true
    }
    
    // MARK: - Networking
    private func cancellLoadingTask(){
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    private func startSearch(_ request: String){
        if request == "" {
            resultArticles.removeAll()
            resultsTableView.reloadData()
            tableState = .noResult
            return
        }
        guard let encodedString = request.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return
        }
        cancellLoadingTask()
        resultArticles.removeAll()
        resultsTableView.reloadData()
        tableState = .loadingResult
        
        let components = ["q":encodedString, "pageSize":"100"]
        
        loadingTask = NewsAPIProvider.newsLoadingTask(withParameters: components, completionHandler: self.handleResultsFromArticles(_:))
        
        loadingTask?.resume()
    }
    
    private func handleResultsFromArticles(_ articles : [Article]?){
        guard let articles = articles else {
            DispatchQueue.main.async {
                self.tableState = .noResult
            }
            return
        }
        self.resultArticles.append(contentsOf: articles)
        DispatchQueue.main.async {
            if self.resultArticles.count != 0{
                self.tableState = .presentingResult
                self.resultsTableView.reloadData()
            }else{
                self.tableState = .noResult
            }
        }
    }
    
    // MARK: - Configure Table View background appearance
    
    private func configureTableBackground() {
        let backgroundView = UIView(frame: resultsTableView.frame)
        resultsTableView.backgroundView = backgroundView
        
        backgroundView.addSubview(emptyLabel)
        configureEmptyLabel()
        
        backgroundView.addSubview(refreshActivity)
        configureRefreshActivity()
    }
    
    private func configureEmptyLabel() {
        emptyLabel.text = "No search results"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = UIColor.lightGray
        emptyLabel.font = UIFont.boldSystemFont(ofSize: 36)
        emptyLabel.isHidden = false
        configureTableBackroundConstaints(forView: emptyLabel, size: CGSize(width: resultsTableView.frame.size.width, height: 40))
    }
    
    private func configureRefreshActivity() {
        if #available(iOS 13.0, *) {
            refreshActivity.style = .large
        } else {
            refreshActivity.style = .whiteLarge
        }
        refreshActivity.color = .gray
        refreshActivity.isHidden = true
        configureTableBackroundConstaints(forView: refreshActivity, size: CGSize(width: 40, height: 40))
    }
    
    private func configureTableBackroundConstaints(forView view: UIView, size: CGSize) {
        view.translatesAutoresizingMaskIntoConstraints = false
        guard let backgroundView = view.superview else {
            return
        }
        
        NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.width).isActive = true
        NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: size.height).isActive = true
        NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem:backgroundView , attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem:backgroundView , attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
}



    
        

