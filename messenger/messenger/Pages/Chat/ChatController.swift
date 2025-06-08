import UIKit
import Alamofire
import Starscream

struct SocketMessage: Codable {
    let message: String?
    let file: String?
}

struct FileResponse: Decodable {
    let filePath: String
}


class ChatController: UIViewController {
    
    // MARK: - Properties
    private var socket: WebSocket?
    private var selectedImage: UIImage?
    private var messages: [Message] = []
    private var chatID: String?
    
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.register(CustomMessageCell.self, forCellReuseIdentifier: CustomMessageCell.reuseIdentifier)
        tv.estimatedRowHeight = 100
        tv.rowHeight = UITableView.automaticDimension
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var messageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 8
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray3.cgColor
        tv.font = .systemFont(ofSize: 16)
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private lazy var sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var attachButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "paperclip"), for: .normal)
        btn.tintColor = .systemGray
        btn.addTarget(self, action: #selector(handleAttach), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var messageContainerBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        loadChatHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connectWebSocket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disconnectWebSocket()
    }
    
    // MARK: - Configuration
    func configureChat(chatID: String) {
        self.chatID = chatID
        messages = []
        connectWebSocket()
    }
}

// MARK: - UI Setup
extension ChatController {
    private func setupUI() {
        view.backgroundColor = .white
        
        // Добавляем элементы в правильном порядке
        view.addSubview(tableView)
        view.addSubview(messageContainerView) // Добавляем контейнер ДО настройки констрейнтов
        
        setupTableView()
        setupMessageContainer()
    }
    
    private func setupTableView() {
        // Удаляем добавление tableView здесь, т.к. уже добавили в setupUI()
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageContainerView.topAnchor) // Теперь messageContainerView уже в иерархии
        ])
    }
    
    private func setupMessageContainer() {
        view.addSubview(messageContainerView)
        
        messageContainerView.addSubview(attachButton)
        messageContainerView.addSubview(textView)
        messageContainerView.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            messageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            attachButton.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 16),
            attachButton.centerYAnchor.constraint(equalTo: messageContainerView.centerYAnchor),
            attachButton.widthAnchor.constraint(equalToConstant: 24),
            attachButton.heightAnchor.constraint(equalToConstant: 24),
            
            textView.leadingAnchor.constraint(equalTo: attachButton.trailingAnchor, constant: 8),
            textView.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -8),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            sendButton.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: messageContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        messageContainerBottomConstraint = messageContainerView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor
        )
        messageContainerBottomConstraint.isActive = true
    }
}

// MARK: - TableView DataSource & Delegate
extension ChatController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomMessageCell.reuseIdentifier, for: indexPath) as! CustomMessageCell
        let message = messages[indexPath.row]
        cell.configure(
            user_id: message.user?.id ?? "",
            message: message.message,
            UserDefaultsHelper.shared.id ?? "",
            photo_url: message.user?.photo,
            fileUrl: message.file
        )
        return cell
    }
}

// MARK: - WebSocket Handling
extension ChatController: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .text(let text):
            DispatchQueue.main.async {
                self.handleIncomingMessage(text)
            }
        case .connected:
            print("WebSocket connected")
        case .disconnected:
            print("WebSocket disconnected")
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown")")
        default: break
        }
    }
    
    private func connectWebSocket() {
        guard let userID = UserDefaultsHelper.shared.id, let chatID = chatID else { return }
        let url = URL(string: "wss://test.bytecode.su/ws/\(userID)/\(chatID)")!
        print(url)
        socket = WebSocket(request: URLRequest(url: url))
        socket?.delegate = self
        socket?.connect()
    }
    
    private func disconnectWebSocket() {
        socket?.disconnect()
        socket = nil
    }
}

// MARK: - Message Handling
extension ChatController {
    private func handleIncomingMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(Message.self, from: data) else { return }
        
        messages.append(message)
        tableView.reloadData()
        scrollToBottom()
    }
    
    @objc private func handleSend() {
        guard !textView.text.isEmpty || selectedImage != nil else { return }
        
        if selectedImage != nil {
            uploadImageToServer { [weak self] filePath in
                self?.sendMessage(filePath: filePath)
            }
        } else {
            sendMessage(filePath: nil)
        }
    }
    
    private func sendMessage(filePath: String?) {
        let message = SocketMessage(message: textView.text, file: filePath)
        guard let data = try? JSONEncoder().encode(message),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        
        socket?.write(string: jsonString)
        textView.text = ""
        selectedImage = nil
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - Image Handling
extension ChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc private func handleAttach() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        selectedImage = image
    }
    
    private func uploadImageToServer(completion: @escaping (String) -> Void) {
        guard let image = selectedImage,
              let chatID = chatID,
              let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        
        AF.upload(
            multipartFormData: { $0.append(imageData, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg") },
            to: "\(APIService.baseUrl)/files/\(chatID)/upload",
            headers: APIService.getAuthorizationHeaders()
        ).responseDecodable(of: FileResponse.self) { response in
            switch response.result {
            case .success(let fileResponse):
                completion(fileResponse.filePath)
            case .failure(let error):
                print("Upload error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Network
extension ChatController {
    private func loadChatHistory() {
        guard let chatID = chatID else { return }
        
        AF.request(
            "\(APIService.baseUrl)/chats/messages/\(chatID)",
            headers: APIService.getAuthorizationHeaders()
        ).responseDecodable(of: [Message].self) { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let messages):
                self.messages = messages
                self.tableView.reloadData()
                self.scrollToBottom()
            case .failure(let error):
                print("History load error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Keyboard Handling
extension ChatController {
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        messageContainerBottomConstraint.constant = -keyboardHeight
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            self.scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        messageContainerBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}
