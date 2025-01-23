import UIKit
import Alamofire
import Starscream
class ChatController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        
        switch event {
        case .connected(let headers):
            print("Connected: \(headers)")
        case .disconnected(let reason, let code):
            print("Disconnected: \(reason) (\(code))")
        case .text(let text):
            let msg = try? JSONDecoder().decode(Message.self, from: text.data(using: .utf8)!)
            self.chat_info?.messages.append(msg!)
            self.tableView.reloadData()
            self.scrollToBottom()
        case .error(let error):
            print("Error: \(error?.localizedDescription ?? "Unknown")")
        default:
            break
        }
    }
    
    
    func send(message: String) {
        self.socket?.write(string: message)
        self.textView.text = ""
    }
    
    
    private var socket: WebSocket?
    
    // MARK - WebSockets
    func connect(chat_id: String) {
        let my_id: String? = UserDefaultsHelper.shared.id
        guard let id = my_id else {
            AlertManager.pushPrimitiveAlert(to: self, title: "Не удалось законнектиться", desc: "абшибка")
            return
        }
        
        let url = URL(string: "wss://test.bytecode.su/ws/\(id)/\(chat_id)")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    
    @objc func handleSend() {
        if (self.textView.text.isEmpty == true) {
            return
        }
        
        self.send(message: self.textView.text)

    }
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let messageContainerView = UIView()
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    
    // MARK: - Constraints
    private var messageContainerBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Data
    var chat_info: ChatHistory?
    var chat: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        configureTableView()
        
        self.connect(chat_id: self.chat!)
        
        self.sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChatHistory()
    }
    
    // MARK: - Configuration
    func configureChat(chat_id: String) {
        self.chat = chat_id
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CustomMessageCell", bundle: nil),
                         forCellReuseIdentifier: "CustomMessage")
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat_info?.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomMessage", for: indexPath) as! CustomMessageCell
        if let message = chat_info?.messages[indexPath.row] {
            
            cell.setupCell(message: message, UserDefaultsHelper.shared.id!)
            
        }
        return cell
    }
    
    func scrollToBottom() {
        let lastSection = tableView.numberOfSections - 1
        guard lastSection >= 0 else { return }
        let lastRow = tableView.numberOfRows(inSection: lastSection) - 1
        guard lastRow >= 0 else { return }
        
        let indexPath = IndexPath(row: lastRow, section: lastSection)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    // Вызывайте этот метод при добавлении нового сообщения
    
    // MARK: - Network
    private func loadChatHistory() {
        guard let chatID = chat else { return }
        
        AF.request(
            "\(APIService.baseUrl)/chats/messages/\(chatID)",
            method: .get,
            headers: APIService.getAuthorizationHeaders()
        ).responseDecodable(of: ChatHistory.self) { [weak self] response in
            switch response.result {
            case .success(let history):
                self?.chat_info = history
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.scrollToBottom()
                }
            case .failure(let error):
                print("Error loading chat history:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // TableView Constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Message Container
        messageContainerView.backgroundColor = .systemGray6
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageContainerView)
        
        // TextView Setup
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        messageContainerView.addSubview(textView)
        
        // Send Button Setup
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = .systemBlue
        sendButton.layer.cornerRadius = 8
        messageContainerView.addSubview(sendButton)
        
        // Constraints Setup
        NSLayoutConstraint.activate([
            // TableView
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageContainerView.topAnchor),
            
            // Message Container
            messageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            // TextView
            textView.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -8),
            textView.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            // Send Button
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
    
    // MARK: - Keyboard Handling
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
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        messageContainerBottomConstraint.constant = -keyboardHeight
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            self.scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        messageContainerBottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Message Handling

    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
