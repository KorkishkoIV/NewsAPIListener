//
//  LoadingTableViewCell.swift
//  NewsListener12
//
//  Created by ivan chelovekov on 17.10.2021.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    
    let refreshControll = UIActivityIndicatorView()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if #available(iOS 13.0, *) {
            refreshControll.style = .large
        } else {
            refreshControll.style = .whiteLarge
        }
        contentView.addSubview(refreshControll)
        refreshControll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: refreshControll, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60).isActive = true
        NSLayoutConstraint(item: refreshControll, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60).isActive = true
        NSLayoutConstraint(item: refreshControll, attribute: .centerX, relatedBy: .equal, toItem:self.contentView , attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: refreshControll, attribute: .centerY, relatedBy: .equal, toItem:self.contentView , attribute: .centerY, multiplier: 1, constant: 0).isActive = true        
        refreshControll.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
