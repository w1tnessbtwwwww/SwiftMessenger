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
        label.textColor = .black
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
    
    private let messageImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        iv.isHidden = true
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    // MARK: - Constraints
    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?
    private var imageHeightConstraint: Constraint?
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        messageLabel.text = nil
        messageImageView.image = nil
        messageImageView.isHidden = true
        imageHeightConstraint?.update(offset: 0)
    }
    
    // MARK: - Configuration
    func configure(user_id: String, message: String?, _ myId: String, photo_url: String?, fileUrl: String?) {
        messageLabel.text = message
        
        if user_id == myId {
            setupMyMessageStyle()
        } else {
            setupOtherMessageStyle(photo_url: photo_url)
        }
        
        configureImage(fileUrl: fileUrl)
    }
    
    private func setupMyMessageStyle() {
        bubbleView.backgroundColor = .systemBlue
        messageLabel.textColor = .white
        messageLabel.textAlignment = .right
        avatarImageView.isHidden = true
        leadingConstraint?.deactivate()
        trailingConstraint?.activate()
    }
    
    private func setupOtherMessageStyle(photo_url: String?) {
        bubbleView.backgroundColor = .systemGray3
        messageLabel.textColor = .black
        messageLabel.textAlignment = .left
        avatarImageView.isHidden = false
        trailingConstraint?.deactivate()
        leadingConstraint?.activate()
        
        if let url = photo_url {
            avatarImageView.kf.setImage(with: URL(string: url))
        }
    }
    
    private func configureImage(fileUrl: String?) {
        guard let fileUrl = fileUrl, let url = URL(string: fileUrl) else {
            messageImageView.isHidden = true
            imageHeightConstraint?.update(offset: 0)
            return
        }
        
        messageImageView.isHidden = false
        messageImageView.kf.setImage(with: url) { [weak self] result in
            guard let self = self, case .success(let value) = result else { return }
            
            let maxBubbleWidth = UIScreen.main.bounds.width * 0.75 - 24
            let aspectRatio = value.image.size.width / value.image.size.height
            let calculatedHeight = min(300, maxBubbleWidth / aspectRatio)
            
            self.imageHeightConstraint?.update(offset: calculatedHeight)
            self.layoutIfNeeded()
            
            if let tableView = self.superview as? UITableView {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
    
    // MARK: - Setup
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageImageView)
        bubbleView.addSubview(messageLabel)
    }
    
    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8).priority(.high)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
        }
        
        messageImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(12)
            imageHeightConstraint = make.height.equalTo(0).constraint
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(messageImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12).priority(.high)
        }
        
        bubbleView.snp.prepareConstraints { make in
            leadingConstraint = make.leading.equalTo(avatarImageView.snp.trailing).offset(8).constraint
            trailingConstraint = make.trailing.equalToSuperview().offset(-8).constraint
        }
        
        leadingConstraint?.deactivate()
        trailingConstraint?.deactivate()
    }
}
