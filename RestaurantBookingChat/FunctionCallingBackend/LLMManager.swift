//
//  LLMManager.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/2/24.
//

import AI
import OpenAI
import CorePersistence

final class LLMManager: ObservableObject {
    @Published var client: any LLMRequestHandling = OpenAI.Client(apiKey: nil)
    @Published var model: OpenAI.Model = .gpt_3_5
    
    let configuration: RestaurantBookingChatbotConfiguration
    
    var systemPrompt: RestaurantBookingChatbotSystemPrompt {
        RestaurantBookingChatbotSystemPrompt(configuration: configuration)
    }
    
    init(configuration: RestaurantBookingChatbotConfiguration) {
        self.configuration = configuration
    }
    
    func bookRestaurant(
        from chat: Chat
    ) async -> BookRestaurantFunctionParameters {
        let messages: [AbstractLLM.ChatMessage] = chat.toChatMessages(systemPrompt: systemPrompt.generateSystemMessage())
        
        do {
            let functionCall: AbstractLLM.ChatFunctionCall = try await client.complete(
                messages,
                functions: [BookRestaurantFunctionDefinitions.bookRestaurantFunction],
                model: model,
                as: .functionCall
            )
            
            let result = try functionCall.decode(BookRestaurantFunctionParameters.self)
            
            return result
        } catch {
            runtimeIssue(error)
        }
        
        return BookRestaurantFunctionParameters()
    }
    
    func bookRestaurantWithAutomaticMessages(
        from chat: Chat
    ) async -> Either<BookRestaurantFunctionParameters, String> {
        let messages: [AbstractLLM.ChatMessage] = chat.toChatMessages(systemPrompt: systemPrompt.generateSystemMessage())
        
        do {
            let functionCallOrMessage: Either<AbstractLLM.ChatFunctionCall, AbstractLLM.ChatMessage> = try await client.complete(
                messages,
                functions: [
                    BookRestaurantFunctionDefinitions.bookRestaurantFunctionWithAllParametersMandatory
                ],
                model: model,
                as: .either(.functionCall, or: .chatMessage)
            )
            
            switch functionCallOrMessage {
                case .left(let functionCall):
                    let result = try functionCall.decode(BookRestaurantFunctionParameters.self)
                    
                    return .left(result)
                case .right(let message):
                    let messageText = try String(message)
                    
                    return .right(messageText)
            }
        } catch {
            runtimeIssue(error)
            
            return .right("An unexpected error occured!")
        }
    }
    
    func bookRestaurantWithAutomaticMessagesAndInvalidIntentRejection(
        from chat: Chat
    ) async -> Either<BookRestaurantFunctionParameters, String> {
        let messages: [AbstractLLM.ChatMessage] = chat.toChatMessages(systemPrompt: systemPrompt.generateSystemMessage())
        
        do {
            let functions: [AbstractLLM.ChatFunctionDefinition] = [
                BookRestaurantFunctionDefinitions.bookRestaurantFunctionWithAllParametersMandatory,
                try RejectInvalidUserQueryFunction.toChatFunctionDefinition()
            ]
            
            let functionCallOrMessage: Either<AbstractLLM.ChatFunctionCall, AbstractLLM.ChatMessage> = try await client.complete(
                messages,
                functions: functions,
                model: model,
                as: .either(.functionCall, or: .chatMessage)
            )
            
            switch functionCallOrMessage {
                case .left(let functionCall):
                    if functionCall.name == RejectInvalidUserQueryFunction.name {
                        let result: RejectInvalidUserQueryFunction.Parameters = try functionCall.decode(RejectInvalidUserQueryFunction.Parameters.self)
                        
                        return .right(result.reason_for_rejection)
                    } else {
                        let result = try functionCall.decode(BookRestaurantFunctionParameters.self)
                        
                        return .left(result)
                    }
                case .right(let message):
                    let messageText = try String(message)
                    
                    return .right(messageText)
            }
        } catch {
            runtimeIssue(error)
        }
        
        return .right("Oops! I didn't catch that. Please let me know again which restaurant you'd like to book and when!")
    }
}
