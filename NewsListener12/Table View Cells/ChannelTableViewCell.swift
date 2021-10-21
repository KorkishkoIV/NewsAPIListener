import Foundation
import UIKit

class ChannelTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var favored:Bool = false{
        didSet{
            changeButtonImage()
        }
    }
    var addToFavoriteButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 13.0, *) {
            addToFavoriteButton = UIButton(type: .custom)
        } else {
            addToFavoriteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        }
        guard let button = addToFavoriteButton else {
            return
        }
        self.accessoryView = button
        button.sizeToFit()
        changeButtonImage()
        button.addTarget(self, action: #selector(addToFavoriteButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func addToFavoriteButtonTapped(_ sender: UIButton){
        self.favored = !favored
        guard let tableView = self.superview as? UITableView else {
            return
        }
        guard let indexPath = tableView.indexPath(for: self) else {
            return
        }
        tableView.delegate?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
    }
    
    func changeButtonImage(){
        guard let button = addToFavoriteButton else {
            return
        }
        if #available(iOS 13.0, *) {
            let image = UIImage(systemName: (favored) ? "star.fill" : "star")
            button.setImage(image, for: .normal)
        } else {
            let image = UIImage(named: (favored) ? "StarFill50" : "Star50")
            button.setImage(image, for: .normal)
        }
    }
}
