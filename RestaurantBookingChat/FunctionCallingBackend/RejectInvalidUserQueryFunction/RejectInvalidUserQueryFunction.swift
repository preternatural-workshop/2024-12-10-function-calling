//
//  RestaurantBookingVerificationInput.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/8/24.
//

import AI
import CorePersistence

struct RejectInvalidUserQueryFunction {
    
    struct Parameters: Codable, Hashable, Initiable, Sendable {
        @JSONSchemaDescription("The reason the user's message has been flagged as an invalid intent.")
        var reason_for_rejection: String
        
        @JSONSchemaDescription("The category of the invalid intent parsed from the user's message.")
        var invalid_intent_category: String?
        
        init() {
            
        }
    }
    
    static var name: AbstractLLM.ChatFunction.Name {
        "reject_invalid_user_query"
    }
    
    static var context: String {
        """
        Call this function to report an invalid user query. Reject any user queries that don't pertain to restaurant booking.
        """
    }
    
    static func toChatFunctionDefinition() throws -> AbstractLLM.ChatFunctionDefinition {
        AbstractLLM.ChatFunctionDefinition(
            name: name,
            context: context,
            parameters: try JSONSchema(reflecting: Parameters.self)
        )
    }
}
