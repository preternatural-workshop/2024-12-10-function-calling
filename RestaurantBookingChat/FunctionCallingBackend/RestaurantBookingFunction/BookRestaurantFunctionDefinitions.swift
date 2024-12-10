//
//  RestaurantBookingFunction.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/7/24.
//

import AI
import CorePersistence

struct RestaurantBookingChatbotConfiguration {
    private(set) var strategy: RestaurantBookingChatbotStrategy
    private(set) var rejectInvalidIntents: Bool
    
    init(
        strategy: RestaurantBookingChatbotStrategy,
        rejectInvalidIntents: Bool = false
    ) {
        self.strategy = strategy
        self.rejectInvalidIntents = rejectInvalidIntents
    }
    
    static var manualResponse: Self {
        Self(strategy: .manualResponse)
    }
    
    static var automaticResponse: Self {
        Self(strategy: .automaticResponse)
    }
    
    func rejectingInvalidIntents() -> Self {
        var result = self
        
        result.rejectInvalidIntents = true
        
        return result
    }
}

enum RestaurantBookingChatbotStrategy {
    case manualResponse
    case automaticResponse
}

struct RestaurantBookingChatbotSystemPrompt {
    let configuration: RestaurantBookingChatbotConfiguration
    
    // Note that the LLM is trained with a cutoff date. So make sure to specify today's date in the system or user prompt for correct interpretation of relative time descriptions such as "tomorrow".
    static var systemMessageManualResponse: PromptLiteral {
        """
        You are a helpful assistant tasked with booking restaurant reservations. 
        
        Please gather the following details efficiently:
        1. Name of the restaurant
        2. Date of the reservation
        3. Time of the reservation
        4. Number of people attending.
        
        Rules for calling `book_restaurant`:
        1. If the user doesn't provide a piece of information, simple pass NULL for that parameter. 
        2. If the user doesn't provide any information, pass NULL for all parameters.
        3. Pass NULL for parameters that you don't have the information for. 
        
        Always call `book_restaurant`.
        
        DO NOT ADD ANY ADDITIONAL INFORMATION. 
        
        Today's date is \(Date().mediumStyleDateString)
        """
    }
    
    static var systemMessageForBookingWithAutomaticMessages: PromptLiteral {
        """
        You are a helpful assistant tasked with booking restaurant reservations. 
        
        Please gather the following details efficiently:
        1. Name of the restaurant
        2. Date of the reservation
        3. Time of the reservation
        4. Number of people attending.
        
        Call the 'book_restaurant' function once ALL the restaurant booking details have been gathered.
        
        Today's date is \(Date().mediumStyleDateString)
        """
    }
    
    static var rejectInvalidUserIntentsInstructions: PromptLiteral {
        """
        
        If the user asks something that is out-of-scope of restaurant booking, call \(RejectInvalidUserQueryFunction.name) appropriately. Do not call `book_restaurant` in that case.
        """
    }
    
    func generateSystemMessage() -> PromptLiteral {
        var result: PromptLiteral = ""
        
        switch configuration.strategy {
            case .manualResponse:
                result = Self.systemMessageManualResponse
            case .automaticResponse:
                result = Self.systemMessageForBookingWithAutomaticMessages
        }
        
        if configuration.rejectInvalidIntents {
            result.append(Self.rejectInvalidUserIntentsInstructions)
        }
        
        return result
    }
}

struct BookRestaurantFunctionDefinitions {
    
    
    static let bookRestaurantFunction = AbstractLLM.ChatFunctionDefinition(
        name: "book_restaurant",
        context: "Make a restaurant booking",
        parameters: JSONSchema(
            type: .object,
            description: "Required data to make a restaurant booking",
            properties: [
                "restaurant_name": JSONSchema(
                    type: .string,
                    description: "The name of the restaurant",
                    required: false
                ),
                "reservation_date" : JSONSchema(
                    type: .string,
                    description: "The date of the restaurant booking in yyyy-MM-dd format. Should be a date with a year, month, day. NOTHING ELSE",
                    required: false
                ),
                "reservation_time" : JSONSchema(
                    type: .string,
                    description: "The time of the reservation in HH:mm format. Should include hours and minutes. NOTHING ELSE",
                    required: false
                ),
                "number_of_guests" : JSONSchema(
                    type: .integer,
                    description: "The total number of people the reservation is for",
                    required: false
                )
            ],
            required: false
        )
    )
    
    static var bookRestaurantFunctionWithAllParametersMandatory: AbstractLLM.ChatFunctionDefinition {
        var function = bookRestaurantFunction
        
        function.parameters.disableAdditionalPropertiesRecursively()
        
        return function
    }
}
