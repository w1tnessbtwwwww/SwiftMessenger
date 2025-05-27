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

class ChatController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {

    // MARK: - Properties
    private var socket: WebSocket?
    private var selectedImage: UIImage?

    // MARK: - UI Elements
    private let tableView = UITableView()
    private let messageContainerView = UIView()
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    private let attachButton = UIButton(type: .system)

    // MARK: - Constraints
    private var messageContainerBottomConstraint: NSLayoutConstraint!

    // MARK: - Data
    var messages: [Message] = []
    var chat: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        configureTableView()
        connect(chat_id: chat ?? "")
        setupButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChatHistory()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanup()
    }

    // MARK: - Configuration
    func configureChat(chat_id: String) {
        messages = []
        chat = chat_id
        connect(chat_id: chat_id)
        loadChatHistory()
    }

    // MARK: - WebSocket
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("Connected: \(headers)")
        case .disconnected(let reason, let code):
            print("Disconnected: \(reason) (\(code))")
        case .text(let text):
            handleIncomingMessage(text)
        case .error(let error):
            print("Error: \(error?.localizedDescription ?? "Unknown")")
        default: break
        }
    }

    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomMessageCell.reuseIdentifier, for: indexPath) as! CustomMessageCell
        let message = messages[indexPath.row]
        cell.configure(
            user_id: message.user!.id!,
            message: message.message,
            UserDefaultsHelper.shared.id ?? "",
            photo_url: message.user?.photo ?? "",
            fileUrl: message.file
        )
        return cell
    }
}

// MARK: - Setup & Handlers
extension ChatController {
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(messageContainerView)
        configureTableView()
        setupMessageContainer()
    }

    private func setupButtons() {
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        attachButton.addTarget(self, action: #selector(handleAttach), for: .touchUpInside)
    }

    private func setupMessageContainer() {
        messageContainerView.backgroundColor = .systemGray6
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false

        attachButton.translatesAutoresizingMaskIntoConstraints = false
        attachButton.setImage(UIImage(systemName: "paperclip"), for: .normal)
        attachButton.tintColor = .systemGray
        messageContainerView.addSubview(attachButton)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        messageContainerView.addSubview(textView)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.layer.cornerRadius = 8
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

        messageContainerBottomConstraint = messageContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        messageContainerBottomConstraint.isActive = true
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(CustomMessageCell.self, forCellReuseIdentifier: CustomMessageCell.reuseIdentifier)
        tableView.estimatedRowHeight = 119
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageContainerView.topAnchor)
        ])
    }
}

// MARK: - Image Handling
extension ChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc private func handleAttach() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        selectedImage = image
    }
}

// MARK: - Network
extension ChatController {
    private func uploadImageToServer(completion: @escaping (String) -> Void) {
        guard let image = selectedImage,
              let chatID = chat,
              let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        
        print(imageData)
        AF.upload(
            multipartFormData: { multipart in
                multipart.append(imageData, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
            },
            to: "\(APIService.baseUrl)/files/\(chatID)/upload",
            method: .post,
            headers: APIService.getAuthorizationHeaders()
        ).responseDecodable(of: FileResponse.self) { [weak self] response in
            print(String(data: response.data!, encoding: .utf8))
            switch response.result {
            case .success(let fileResponse):
                completion(fileResponse.filePath)
            case .failure(let error):
                AlertManager.pushPrimitiveAlert(to: self!, title: "Ошибка", desc: "Ошибка загрузки: \(error.localizedDescription)")
            }
        }
    }

    private func loadChatHistory() {
        guard let chatID = chat else { return }
        AF.request(
            "\(APIService.baseUrl)/chats/messages/\(chatID)",
            headers: APIService.getAuthorizationHeaders()
        ).responseDecodable(of: [Message].self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let history):
                self.messages = history
                self.tableView.reloadData()
                self.scrollToBottom()
            case .failure(let error):
                print("Error loading history:", error.localizedDescription)
            }
        }
    }
}

// MARK: - Message Handling
extension ChatController {
    private func handleIncomingMessage(_ text: String) {
        guard let msg = try? JSONDecoder().decode(Message.self, from: text.data(using: .utf8)!) else { return }
        messages.append(msg)
        tableView.reloadData()
        scrollToBottom()
    }

    @objc private func handleSend() {
        guard !textView.text.isEmpty || selectedImage != nil else { return }

        if let image = selectedImage {
            uploadImageToServer { [weak self] filePath in
                guard let self = self else { return }
                self.send(message: SocketMessage(message: self.textView.text, file: filePath))
                self.textView.text = ""
                self.selectedImage = nil
            }
        } else {
            send(message: SocketMessage(message: textView.text, file: nil))
            textView.text = ""
        }
    }

    private func send(message: SocketMessage) {
        guard let data = try? JSONEncoder().encode(message),
              let json = String(data: data, encoding: .utf8) else { return }
        socket?.write(string: json)
    }

    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - WebSocket & Cleanup
extension ChatController {
    private func connect(chat_id: String) {
        guard let id = UserDefaultsHelper.shared.id else {
            AlertManager.pushPrimitiveAlert(to: self, title: "Ошибка", desc: "Не удалось подключиться")
            return
        }

        let url = URL(string: "wss://test.bytecode.su/ws/\(id)/\(chat_id)")!
        let request = URLRequest(url: url)
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }

    private func cleanup() {
        messages = []
        chat = nil
        socket?.disconnect()
        socket = nil
    }
}

// MARK: - Keyboard Handling
extension ChatController {
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
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
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

        messageContainerBottomConstraint.constant = 0
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
}
