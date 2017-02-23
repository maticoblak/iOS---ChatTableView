//
//  ChatController.swift
//  ChatTableView
//
//  Created by Matic Oblak on 2/23/17.
//  Copyright © 2017 Kamino. All rights reserved.
//

import UIKit

/// Designed to manage the messages retreived from server
class ChatController {
    
    /// The id of the chat that needs to be called to
    var chatID: String
    
    /// Current loaded messages
    fileprivate(set) var currentMessages: [Message]?
    
    /// Main intitializer
    ///
    /// - Parameter chatID: The id of the chat
    init(chatID: String) {
        self.chatID = chatID
        ChatController.startMockingConversation() // Start mocking here. Should be removed for real data
    }
    
    /// Loads a fresh data. Previous data will be deleted
    ///
    /// - Parameter callback: <#callback description#>
    func loadFresh(callback: ((_ newMessages: [Message]?, _ error: Error?) -> Void)?) {
        currentMessages = nil // clear current data source
        
        // Mocking request
        DispatchQueue(label: "Mocked delay").async {
            Thread.sleep(forTimeInterval: 1.0) // wait one second
            DispatchQueue.main.async {
                self.currentMessages = ChatController.mockedMessages
                callback?(self.currentMessages, nil)
            }
        }
    }
    
    /// Loads only messages that are newer then a specific ID
    ///
    /// - Parameters:
    ///   - messageID: ID of the newest message
    ///   - callback: Will be called once the request is complete and data inserted
    func loadNewer(thenID messageID: String, callback: ((_ newMessages: [Message]?, _ error: Error?) -> Void)?) {
        
        // Only here because of mocking
        guard let messageValue: Int = Int(messageID) else {
            callback?(nil, NSError(domain: "Mocked", code: 400, userInfo: nil))
            return
        }
        
        // Mock server request
        DispatchQueue(label: "Mocked delay").async {
            Thread.sleep(forTimeInterval: 1.0) // wait one second
            DispatchQueue.main.async {
                
                // This is mocking. We only insert the new messages
                let newMessages = ChatController.mockedMessages.filter({ message -> Bool in
                    // Check is newer
                    if let integerValue = Int(message.id), integerValue > messageValue {
                        return true
                    } else {
                        return false
                    }
                })
                
                self.currentMessages = {
                    guard let messages = self.currentMessages else {
                        return newMessages
                    }
                    return messages + newMessages
                }()
                
                // callback
                callback?(newMessages, nil)
            }
        }
        
    }

}

// MARK: - Message model

extension ChatController {
    
    class Message {
        
        var id: String = ""
        var text: String?
        
    }
    
}

// MARK: - Data mocking

fileprivate extension ChatController {
    
    static var mockedMessages: [Message] = [Message]()
    static var mockTimer: Timer?
    private static var currentIndex = 1
    
    static func startMockingConversation() {
        
        if mockTimer == nil {
            let mockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onMockTimer), userInfo: nil, repeats: true)
            self.mockTimer = mockTimer
        }
        
    }
    static func stopMockingConversation() {
        
        mockTimer?.invalidate()
        mockTimer = nil
        
    }
    
    @objc private static func onMockTimer() {
    
        let mockedTexts: [String] = [
            "Hello",
            "How are you doing",
            "Not bad, and you? I just woke up and drinking my coffee. I can feel this is going to be a nice day!",
            "Thanks, my mistake the block wasn't from the reloadData. After loading i scroll to the bottom of the tableView and that blocks the thread. tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)\nAny suggestions how to fix this?",
            "Ah well that one might be a problem. Do you have fixed cell heights? Maybe try to compute the offset manually and use setContentOffset. I am not sure if it will fix it but do try.",
            "No fixed heights. its a chat app so all height are dynamically calculated. Is there maybe another way to flip the tableView to start from bottom?",
            "So I assume the first load is the only problem and in it there is no reason to animate it. When you get the first batch try to use the estimated height to compute the initial offset. Then set this offset as non animated. After that call the first reloadData on the table view. Then after that use your\nmethod scrollToRow. If it doesn't work at all then first try to change the order so you call the reload first and then change the offset manually.\nI must say in general we don't use table views for the messaging but rather a custom scroll view. The paging should be done as well. But since you are going this way you might simply try to flip the coordinate system. I am not sure if this would work just out of the box but it will not hurt to try it: Reverse the data source so the last message is the first in array. Then put the table view on some UIView which has a flipped transform (scale(1.0,-1.0)). This should produce a flipped view. Now also flip each of the cells. So ensure that the cell has another view with the same flipped transform.",
            "Thanks, but both ways didn't change anything.\nI will ry the transform, wouldn't this also flip my cells?",
            "Unfortunately iOS does not provide a good tool for a situation such as messaging. There should be some open source libraries that do exactly that though. Maybe try those.\nSo about flipping the views: Yes, using transform on the whole view will flip everything, even the cells. That means you will need to flip each of the cells again so they appear to be correct. Anyway this actually gives you the power to start filling the table view from bottom to the top. You should try it.",
            "Thanks... i will try."
        ]
        
        let index: Int = Int(arc4random())%(mockedTexts.count*3)
        
        if index >= 0 && index < mockedTexts.count {
            let newMessage = Message()
            newMessage.id = "\(currentIndex)"
            newMessage.text = mockedTexts[index]
            self.mockedMessages.append(newMessage)
            currentIndex += 1
        }
    }
    
}
