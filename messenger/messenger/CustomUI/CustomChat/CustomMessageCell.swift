
import Foundation
import UIKit

class CustomMessageCell: UITableViewCell {
    @IBOutlet weak var Message: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func setupCell(message: Message, _ myId: String) {
        self.Message.text = message.message
        if (message.senderId == myId) {
            Message.textAlignment = .right
        }
        else {
            Message.textAlignment = .left
        }
    }

    private func setupViews() {
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
