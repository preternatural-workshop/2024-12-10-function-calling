//
//  ChatFile.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/1/24.
//

import Foundation
import LargeLanguageModels
import Swallow

public struct Chat: Codable, Hashable, Identifiable {
    
    public var id = UUID()
    public var creationDate: Date = Date()
    public var title: String
    public var messages: IdentifierIndexingArrayOf<Chat.Message> = []
    
    static let newChatDefaultTitle = "New Reservation"
    
    init() {
        self.title = Chat.newChatDefaultTitle
        self.messages = [Chat.Message(
            text: "Hello! I'm here to help you make a restaurant booking. Please let me know where you'd like to dine next.",
            role: .assistant
        )]
    }
}

extension Chat {
    func toChatMessages(
        systemPrompt: PromptLiteral
    ) -> [AbstractLLM.ChatMessage] {
        var result: [AbstractLLM.ChatMessage] = [
            .system(systemPrompt)
        ]
        
        self.messages.forEach { message in
            if message.role == .user {
                result.append(.user(message.text))
            } else {
                result.append(.assistant(message.text))
            }
        }
        
        return result
    }
}
