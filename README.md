> [!IMPORTANT]
> Created by [Preternatural AI](https://preternatural.ai/), an exhaustive client-side AI infrastructure for Swift.<br/>
> This project and the frameworks used are presently in alpha stage of development.

# Book a Restaurant via Chat w/ Function Calling

RestaurantBookingChat is a demonstration of using function calling in LLMs to implement a natural language interface to your app's actions. The app simulates a restaurant booking assistant that can manage multiple reservations through natural conversation.
<br/><br/>
[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/PreternaturalAI/AI/blob/main/LICENSE)

## Table of Contents
- [Usage](#usage)
- [Key Concepts](#key-concepts)
- [Preternatural Frameworks](#preternatural-frameworks)
- [Technical Specifications](#technical-specifications)
- [License](#license)

## Usage
#### Supported Platforms
<!-- macOS-->
<p align="left">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/PreternaturalAI/AI/main/Images/macos.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/PreternaturalAI/AI/main/Images/macos-active.svg">
  <img alt="macos" src="https://raw.githubusercontent.com/PreternaturalAI/AI/main/Images/macos-active.svg" height="24">
</picture>&nbsp;
</p>

To install and run RestaurantBookingChat:
1. Download and open the project
2. Add your OpenAI API Key in the `LLMManager` file:

```swift
// LLMManager
@Published var client: any LLMRequestHandling = OpenAI.Client(apiKey: "YOUR_API_KEY")
```
*You can get the OpenAI API key on the [OpenAI developer website](https://platform.openai.com/). Note that you have to set up billing and add a small amount of money for the API calls to work (this will cost you less than 1 dollar).* 

3. Run the project on the Mac
4. Enter details for a restaurant booking. For example: "I'd like to book a table at The French Laundry for tomorrow night at 7pm"
5. Continue the conversation until the booking is done
6. Change the `RestaurantBookingChatbotConfiguration` in `ChatSession` file to the `automaticResponse` strategy to test out Function Calling with the LLM replying to the messages directly.
```swift
// ChatSession
    let configuration = RestaurantBookingChatbotConfiguration(
        strategy: .automaticResponse,
        rejectInvalidIntents: false
    )
```
7. Change the `RestaurantBookingChatbotConfiguration` in `ChatSession` file to `rejectInvalidIntents` (set to `true`) and test out providing an non-restaurant-booking related messages.
  
<img width="748" alt="export47277785-6DB0-40DA-A01A-E1E94689B074" src="https://github.com/user-attachments/assets/ff28b0af-e74c-422d-83d5-42fefdeb9de4" />

## Key Concepts
This app is an introduction to working with Function Calling in LLMs.

## Preternatural Frameworks
The following Preternatural Frameworks were used in this project: 
- [AI](https://github.com/PreternaturalAI/AI): The definitive, open-source Swift framework for interfacing with generative AI.
- [ChatKit](https://github.com/PreternaturalAI/ChatKit/): A protocol-oriented, batteries-included framework for building chat interfaces in Swift.

## Technical Specifications
Function calling is a powerful feature that enables Large Language Models (LLMs) to interact with external tools, APIs, and data sources through well-defined, structured requests. Instead of relying on strictly formatted user inputs, the model can interpret a user’s natural language and translate it into the specific parameters required by a given function. For example, when invoking a `book_restaurant` function, an LLM can identify the necessary details—such as the restaurant name, date, time, and the number of guests—directly from a conversational prompt. While collecting this information might be straightforward in a traditional, form-based interface, achieving the same clarity in voice or chat-based environments is more challenging. By leveraging an LLM’s language understanding capabilities, developers can seamlessly parse natural language instructions and route them into actionable function calls.

This RestaurantBookingChat app shows 3 different strategies to use LLMs for function calling: 

### Manual Response
Under the Manual Response strategy, the LLM identifies any missing or incomplete parameters needed to successfully call the `book_restaurant` function, but it does not automatically format or return a message. Instead, the LLM simply reports back what additional information is needed. The responsibility for deciding how to prompt the user again or how to proceed with partial data then falls to the application developer.

In other words, the Manual Response strategy hands developers the steering wheel once the LLM points out missing details. Your application is then free to craft a suitable user-facing response to request these details explicitly. This is useful if you need full control over the user interaction loop or if your user interface follows a custom logic or workflow that goes beyond a single, direct query.

Example:
If the LLM determines that the user did not specify the number of guests, it might return something like, “Please provide the number of guests for your reservation.” The application can then decide how to present this prompt to the user—through a chat message, a voice prompt, or a UI element—until the information is obtained. Once the user provides the missing parameter, the app can re-invoke the LLM or directly construct the function call.

To activate this mode, set the following `RestaurantBookingChatbotConfiguration` in the `ChatSession` file: 

```swift
// ChatSession
let configuration = RestaurantBookingChatbotConfiguration(
        strategy: .manualResponse,
        rejectInvalidIntents: false
    )
```

The `systemPrompt` is specified in the `BookRestaurantFunctionDefinitions` file as follows:

```swift
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
```

The `bookRestaurantFunction` definition includes all the necessary parameters to call the `book_restaurant` function. Notice that every parameter is set to NOT required. The goal is to return a manual message to the user based on which parameters are missing. 

```swift
// BookRestaurantFunctionDefinitions

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
```

The `bookRestaurant` function is called via the `LLMManager`:

```swift
// LLMManager
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
```

Finally the result can be processed in the `BookRestaurantFunctionResultManager`:

```swift
// BookRestaurantFunctionResultManager

struct BookRestaurantFunctionResultManager {
    private enum BookingParameterName {
        case restaurantName
        case reservationDate
        case reservationTime
        case numberOfGuests
    }
    
    static func makePrompt(
        fromParameters parameters: BookRestaurantFunctionParameters
    ) -> String {
        let missingParameters = getMissingParameters(parameters)
        
        if missingParameters.isEmpty {
            let restaurantName = parameters.restaurantName!
            let reservationDate = parameters.formattedReservationDate!
            let reservationTime = parameters.formattedTime!
            let numberOfGuests = parameters.numberOfGuests!
            
            /* MAKE BOOKING CALL ON THE SERVER */
            
            let prompt = "Great! Your booking at \(restaurantName) on \(reservationDate.formatWithOrdinal()) at \(reservationTime.formatted(use24Hour: false)) for \(numberOfGuests) is confirmed!"
            
            return prompt
        }
        
        return getPromptForMissingParameters(missingParameters)
    }
    
    static func maketitle(
        fromParameters parameters: BookRestaurantFunctionParameters
    ) -> String? {
        let missingParameters = getMissingParameters(parameters)
        
        if missingParameters.isEmpty {
            let restaurantName = parameters.restaurantName!
            let reservationDate = parameters.formattedReservationDate!
            return "\(restaurantName) - \(reservationDate.formatWithOrdinal()) ✅"
        }
        
        if let restaurantName = parameters.restaurantName, let reservationDate = parameters.formattedReservationDate {
            return "\(restaurantName) - \(reservationDate.formatWithOrdinal())"
        }
        
        return nil
    }
}

// MARK: - Missing Parameters Extension
extension BookRestaurantFunctionResultManager {
    private static func getMissingParameters(_ parameters: BookRestaurantFunctionParameters) -> [BookingParameterName] {
        var missingParameters: [BookingParameterName] = []
        
        if parameters.restaurantName == nil { missingParameters.append(.restaurantName) }
        if parameters.formattedReservationDate == nil { missingParameters.append(.reservationDate) }
        if parameters.formattedTime == nil { missingParameters.append(.reservationTime) }
        if parameters.numberOfGuests == nil { missingParameters.append(.numberOfGuests) }
        
        return missingParameters
    }
    
    private static func getPromptForMissingParameters(_ missingParameters: [BookingParameterName]) -> String {
        switch missingParameters {
        // Single missing parameter
        case [.restaurantName]:
            return "Please select a restaurant to complete your booking."
        case [.reservationDate]:
            return "Please select a date for your reservation."
        case [.reservationTime]:
            return "Please select a time for your reservation."
        case [.numberOfGuests]:
            return "Please specify the number of guests for your reservation."
            
        // Two missing parameters
        case [.restaurantName, .reservationDate]:
            return "Please select both a restaurant and a date for your reservation."
        case [.restaurantName, .reservationTime]:
            return "Please select a restaurant and specify the time for your reservation."
        case [.restaurantName, .numberOfGuests]:
            return "Please select a restaurant and specify the number of guests."
        case [.reservationDate, .reservationTime]:
            return "Please select both a date and time for your reservation."
        case [.reservationDate, .numberOfGuests]:
            return "Please select a date and specify the number of guests."
        case [.reservationTime, .numberOfGuests]:
            return "Please specify both the time and number of guests."
            
        // Three missing parameters
        case [.restaurantName, .reservationDate, .reservationTime]:
            return "Please provide the restaurant, date, and time for your reservation."
        case [.restaurantName, .reservationDate, .numberOfGuests]:
            return "Please provide the restaurant, date, and number of guests."
        case [.restaurantName, .reservationTime, .numberOfGuests]:
            return "Please provide the restaurant, time, and number of guests."
        case [.reservationDate, .reservationTime, .numberOfGuests]:
            return "Please provide the date, time, and number of guests."
            
        // All parameters missing
        case [.restaurantName, .reservationDate, .reservationTime, .numberOfGuests]:
            return "Please provide all required booking information: restaurant, date, time, and number of guests."
            
        // Fallback case (shouldn't occur with proper implementation)
        default:
            return "Unable to process your booking. Please check all required information."
        }
    }
}
```

### Automaic Response
Under the Automatic Response strategy, the LLM assumes more responsibility for gathering all necessary parameters before making a function call. Instead of requiring the application to prompt the user for missing information, the LLM proactively interacts with the user—asking questions, clarifying details, and confirming specifics—until it obtains a complete set of parameters. Once the LLM has everything it needs, it automatically constructs and returns a fully formatted function call.

This approach significantly reduces the developer’s workload. Rather than manually detecting missing parameters and issuing follow-up prompts, your application can rely on the LLM to handle these interactions. As a result, users enjoy a more natural conversation, where the AI-driven system seamlessly guides them through the reservation process without interruption or back-and-forth with the application logic.

To activate this mode, set the following `RestaurantBookingChatbotConfiguration` in the `ChatSession` file: 

```swift
// ChatSession
let configuration = RestaurantBookingChatbotConfiguration(
    strategy: .automaticResponse,
    rejectInvalidIntents: false
)
```

The `systemMessage` will be modified with the text to "Call the 'book_restaurant' function once ALL the restaurant booking details have been gathered." as follows:

```swift
// BookRestaurantFunctionDefinitions

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
```

We will also set ALL the `bookRestaurantFunction` properties to be required using this function: 

```swift
static var bookRestaurantFunctionWithAllParametersMandatory: AbstractLLM.ChatFunctionDefinition {
    var function = bookRestaurantFunction
    
    function.parameters.disableAdditionalPropertiesRecursively()
    
    return function
}
```
This will cause the LLM to keep sending messages prompting the user to specify the missing parameters until all of them are present. The `bookRestaurantWithAutomaticMessages` will be called in the `LLMManager`: 

```swift
// LLMManager

// This function returns either ALL the parameters once they are collected, or a chat message structured by the LLM to prompt the user to keep providing the necessary infromation until all the parameters are gathered
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
```

### Automatic Response and Invalid Intent Rejection
One challenge in a chat or voice-based interface is that users may intentionally misuse or stray from the intended purpose of the service. For instance, instead of making a legitimate restaurant reservation, a user might repeatedly submit nonsensical requests, test the system’s limits, or provide irrelevant prompts. Such behavior not only detracts from the user experience but can also incur unnecessary costs, as each model interaction consumes tokens.

To address this issue, the Automatic Response strategy can be combined with an Invalid Intent Rejection mechanism. This involves integrating an additional function designed to detect patterns of misuse or irrelevant prompts. When the LLM encounters user messages that it deems invalid—such as requests that clearly do not align with booking a restaurant—it can invoke this secondary function. The app developer can then decide how to handle these scenarios.

For example, the system could:

* Warn the user that their requests are not valid for this service.
* Temporarily suspend or fully block the user after a certain number of invalid attempts.
* Redirect the user to a help or FAQ resource.
  
By incorporating invalid intent detection, developers can protect their application’s functionality, maintain a high-quality user experience, and control costs associated with serving irrelevant user inputs.

To activate this mode, set the following `RestaurantBookingChatbotConfiguration` in the `ChatSession` file: 

```swift
// ChatSession
let configuration = RestaurantBookingChatbotConfiguration(
    strategy: .automaticResponse,
    rejectInvalidIntents: true
)
```

In this case we will be adding the following user prompt to the automatic `systemMessageForBookingWithAutomaticMessages`:

```swift
// BookRestaurantFunctionDefinitions

static var rejectInvalidUserIntentsInstructions: PromptLiteral {
    """
    
    If the user asks something that is out-of-scope of restaurant booking, call \(RejectInvalidUserQueryFunction.name) appropriately. Do not call `book_restaurant` in that case.
    """
}

```

The `RejectInvalidUserQueryFunction` is set as follows: 

```swift
// RejectInvalidUserQueryFunction

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
```

The `bookRestaurantWithAutomaticMessagesAndInvalidIntentRejection` function is then called in the `LLMManager`:

```swift
// LLMManager

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
```

### Conclusion
In conclusion, these strategies — Manual Response, Automatic Response, and Automatic Response with Invalid Intent Rejection — demonstrate how LLM-driven function calling can be tailored to different application needs and user behavior scenarios. By leveraging the natural language understanding capabilities of LLMs, developers can create more flexible, conversational interfaces that handle parameter gathering, guide users through the reservation process, and even detect irrelevant or malicious requests. Whether you choose a fully manual approach for fine-grained control, an automatic approach for seamless user experiences, or an enhanced strategy that rejects invalid intents, these configurations show how to balance autonomy, user-friendliness, and cost efficiency when building next-generation, voice and chat-based applications.

## License

This package is licensed under the [MIT License](https://github.com/PreternaturalAI/AI/blob/main/LICENSE).





