//
//  ChatSession.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/1/24.
//

import ChatKit
import Merge

@ManagedActor
public final class ChatSession: Logging, ObservableObject {    
    private let taskQueue = TaskQueue()
        
    @PublishedAsyncBinding public var chat: Chat
    
    let configuration = RestaurantBookingChatbotConfiguration(
        strategy: .manualResponse,
        rejectInvalidIntents: false
    )

    lazy var manager: LLMManager = LLMManager(configuration: configuration)
    
    public init(
        chat: PublishedAsyncBinding<Chat>
    ) {
        self._chat = chat
    }
    
    public func sendMessage(
        _ text: String
    ) {
        let message = Chat.Message(text: text, role: .user)
        
        switch configuration.strategy {
            case .manualResponse:
                sendMessageWithManualResponseStrategy(message)
            case .automaticResponse:
                sendMessageWithAutomaticResponseStrategy(message)
        }
    }

    private func sendMessageWithManualResponseStrategy(
        _ message: Chat.Message
    ) {
        chat.messages.append(message)
        
        taskQueue.addTask(priority: .userInitiated) {
            @MainActor in
            
            let parameters: BookRestaurantFunctionParameters = await manager.bookRestaurant(from: chat)
            let prompt: String = BookRestaurantFunctionResultManager.makePrompt(fromParameters: parameters)

            chat.messages.append(Chat.Message(text: prompt, role: .assistant))
          
            if let title = BookRestaurantFunctionResultManager.maketitle(fromParameters: parameters) {
                chat.title = title
            }
        }
    }
    
    private func sendMessageWithAutomaticResponseStrategy(
        _ message: Chat.Message
    ) {
        chat.messages.append(message)
        
        taskQueue.addTask(priority: .userInitiated) {
            @MainActor in
            
            let parametersOrMessage: Either<BookRestaurantFunctionParameters, String>
            
            if !configuration.rejectInvalidIntents {
                parametersOrMessage = await manager.bookRestaurantWithAutomaticMessages(from: chat)
            } else {
                parametersOrMessage = await manager.bookRestaurantWithAutomaticMessagesAndInvalidIntentRejection(from: chat)
            }
            
            switch parametersOrMessage {
                case .left(let parameters): do {
                    let prompt: String = BookRestaurantFunctionResultManager.makePrompt(fromParameters: parameters)
                    
                    chat.messages.append(Chat.Message(text: prompt, role: .assistant))
                   
                    if let title = BookRestaurantFunctionResultManager.maketitle(fromParameters: parameters) {
                        chat.title = title
                    }
                    
                }
                case .right(let message): do {
                    chat.messages.append(Chat.Message(text: message, role: .assistant))
                }
            }
        }
    }
    
    @MainActor
    public func delete(
        _ message: Chat.Message
    ) {
        chat.messages.remove(elementIdentifiedBy: message.id)
    }
}
