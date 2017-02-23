//
//  ChatViewController.swift
//  ChatTableView
//
//  Created by Matic Oblak on 2/23/17.
//  Copyright © 2017 Kamino. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView? // The table view to show messages
    @IBOutlet private weak var chatContainer: UIView? // The view on which the table view is on
    @IBOutlet private weak var textView: UITextView? // The new message text view // TODO: imaplement logic for resizing and sending messages
    
    fileprivate var messagesToShow: [ChatController.Message]? // Current table view data source
    
    private var chatController: ChatController = ChatController(chatID: "mock") // The controller which will handle requests and responses. This should be controled from external item.
    private var pingTimer: Timer? // The timer that keeps getting new messages
    
    /// Will return a new default instance from the storyboard
    ///
    /// - Returns: A new instance of self
    static func instanceFromStoryboard() -> ChatViewController {
        return UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make table view upside down
        chatContainer?.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        
        // Basic information for the table view to have dynamic heights
        tableView?.estimatedRowHeight = 60.0
        tableView?.rowHeight = UITableViewAutomaticDimension
        
        // Initial chat load
        chatController.loadFresh { (items, _) in
            self.messagesToShow = self.chatController.currentMessages // Simply assign the received messages
            self.refreshFromData() // refresh table view
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPing() // Start ping only when the view appears
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPing() // Stop ping when the view disappears
    }
    
    /// Will start to poll the data from server
    private func startPing() {
        if pingTimer == nil {
            pingTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(onPing), userInfo: nil, repeats: true)
        }
    }
    /// Will stop to polling the data from server
    private func stopPing() {
        pingTimer?.invalidate()
        pingTimer = nil
        
    }
    
    /// On poll timer
    @objc private func onPing() {
        
        // If we have a last message then load only from it. Else reload the whole thing
        if let last = messagesToShow?.last?.id {
            
            // Call server to get new messages
            chatController.loadNewer(thenID: last, callback: { (newItems, _) in
                
                // TODO: handle error
                guard let newItems = newItems else {
                    return
                }
                
                // Only refresh if we have some new items
                if newItems.count > 0 {
                    
                    // First mark the table view to begin updates
                    self.tableView?.beginUpdates()
                    
                    // Second update our data source
                    if let current = self.messagesToShow {
                        self.messagesToShow = current + newItems
                    } else {
                        self.messagesToShow = newItems
                    }
                    
                    // Find out what cells we need to inser
                    let newIndexPaths: [IndexPath] = (0..<newItems.count).flatMap { IndexPath(row: $0, section: 0) }
                    self.tableView?.insertRows(at: newIndexPaths, with: .automatic)
                    
                    // Commit changes
                    self.tableView?.endUpdates()
                    
                }
                
            })
        } else {
            // Same as on view did load
            chatController.loadFresh { (items, _) in
                self.messagesToShow = self.chatController.currentMessages
                self.refreshFromData()
            }
        }
        
    }
    
    @IBAction private func sendPressed(_ sender: Any) {
        // TODO: send message
    }
    
    
    /// Convenience for fresh reload
    private func refreshFromData() {
        tableView?.reloadData()
        
        if let messagesToShow = messagesToShow, messagesToShow.count > 0 {
            tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesToShow?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageTableViewCell", for: indexPath) as? ChatMessageTableViewCell {
            let message = messagesToShow?.reversed()[indexPath.row]
            cell.message = message?.text
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    
}
