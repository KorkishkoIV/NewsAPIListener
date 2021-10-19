import UIKit


enum StorageMethod{
    case disk
    case cache
}

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    
    var completionBlock: DispatchWorkItem?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        completionBlock?.cancel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupImage(url: URL?, id: String, method: StorageMethod = .disk){
        guard let unwrapedUrl = url else {
            articleImageView.image = UIImage.placeHolderImage()
            return
        }
        self.articleImageView.image = UIImage.loadingImage()
        
        var imageToSet: UIImage?
        let block = DispatchWorkItem(block: {
            self.articleImageView.image = imageToSet ?? UIImage.placeHolderImage()
        })
        completionBlock = block
        let size = self.frame.size
        
        let provider: ImageProvider = (method == .disk) ? LocalFileManager.instance : ImageCacheManager.instance
        
        provider.asyncGetImage(id: id) { image in
            if let returnedImage = image {
                imageToSet = returnedImage
                DispatchQueue.main.async(execute: block)
            } else {
                guard let loadedImage = UIImage.downsample(imageAt: unwrapedUrl, to: size) else {
                    DispatchQueue.main.async(execute:block)
                    return
                }
                provider.setImage(id: id, image: loadedImage)
                imageToSet = loadedImage
                DispatchQueue.main.async(execute:block)
            }
        }
    }
}
