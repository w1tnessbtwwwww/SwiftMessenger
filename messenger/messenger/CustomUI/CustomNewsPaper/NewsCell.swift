//
//  NewsCell.swift
//  messenger
//
//  Created by Тофик Мамедов on 21.01.2025.
//

import UIKit
import Kingfisher
class NewsCell: UITableViewCell {


    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func setupCell(newsitem: NewsItem) {
        self.descLabel.text = newsitem.description
        self.authorLabel.text = newsitem.author
        self.titleLabel.text = newsitem.title
        
        self.postImage.kf.setImage(with: URL(string: newsitem.image))
    }
    
}
