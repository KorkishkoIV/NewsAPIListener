import UIKit


enum StorageMethod{
    case disk
    case cache
}

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    
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
            changeImage(image: nil)
            return
        }
        changeImage(image: nil, loading: true)
        
        var imageToSet: UIImage?
        let block = DispatchWorkItem(block: {
            self.changeImage(image: imageToSet)
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
    
    private func changeImage (image: UIImage?, loading: Bool = false){
        guard let unwrappedImage = image else {
            articleImageView.isHidden = true
            placeholderLabel.isHidden = false
            placeholderLabel.text = loading ? "Loading article image" : "No artilce image"
            return
        }
        articleImageView.isHidden = false
        articleImageView.image = unwrappedImage
        placeholderLabel.text = ""
        placeholderLabel.isHidden = true
    }
}
