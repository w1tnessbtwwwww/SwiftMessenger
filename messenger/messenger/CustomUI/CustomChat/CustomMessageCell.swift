
import Foundation
import UIKit
import Kingfisher
import SnapKit
class CustomMessageCell: UITableViewCell {
    static let reuseIdentifier = "MessageCell"
    
    // MARK: - UI Elements
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.systemGray3.cgColor
        return iv
    }()
    
    // MARK: - Constraints
    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    public func configure(user_id: String, message: String?, _ myId: String, photo_url: String?, fileUrl: String?) {
        messageLabel.text = message
        
        if user_id == myId {
            // My message (right aligned)
            bubbleView.backgroundColor = UIColor.systemBlue
            messageLabel.textAlignment = .right
            avatarImageView.isHidden = true
            
            // Activate trailing constraint
            leadingConstraint?.deactivate()
            trailingConstraint?.activate()
        } else {
            // Other's message (left aligned with avatar)
            bubbleView.backgroundColor = UIColor.systemGray3
            messageLabel.textAlignment = .left
            avatarImageView.isHidden = false
            
            // Activate leading constraint
            trailingConstraint?.deactivate()
            leadingConstraint?.activate()
            
            if let url = photo_url {
                avatarImageView.kf.setImage(with: URL(string: url))
            }
        }
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(avatarImageView)
        addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        // Avatar constraints
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.width.height.equalTo(32)
        }
        
        // Bubble constraints (base)
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8).priority(.high)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
        }
        
        // Message label constraints
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }
        
        // Dynamic constraints setup
        bubbleView.snp.prepareConstraints { make in
            leadingConstraint = make.leading.equalTo(avatarImageView.snp.trailing).offset(8).constraint
            trailingConstraint = make.trailing.equalToSuperview().offset(-8).constraint
        }
        
        // Initially deactivate both
        leadingConstraint?.deactivate()
        trailingConstraint?.deactivate()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        messageLabel.text = nil
    }
}
