
import Foundation
import UIKit
import Kingfisher
class CustomMessageCell: UITableViewCell {
    @IBOutlet weak var Message: UILabel!

    @IBOutlet weak var messageBorder: UIView!
    @IBOutlet weak var miniIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        self.layer.cornerRadius = 10
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func setupCell(message: Message, _ myId: String, photoUrl: String?) {
        self.Message.text = message.message
        if (message.senderId == myId) {
            Message.textAlignment = .right
        }
        else {
            Message.textAlignment = .left
        }
        
        self.miniIcon.kf.setImage(with: URL(string: photoUrl ?? ""))
    
    }

    private func setupViews() {
        self.messageBorder.layer.cornerRadius = 10
        Message.numberOfLines = 0
        Message.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            Message.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            Message.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            Message.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            Message.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
