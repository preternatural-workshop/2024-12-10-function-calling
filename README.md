> [!IMPORTANT]
> Created by [Preternatural AI](https://preternatural.ai/), an exhaustive client-side AI infrastructure for Swift.<br/>
> This project and the frameworks used are presently in alpha stage of development.

# Book a Restaurant via Chat w/ Function Calling

RestaurantBookingChat is a demonstration of working with function calling in LLMs. The app simulates a restaurant booking assistant that can manage multiple reservations through natural conversation.
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

## License

This package is licensed under the [MIT License](https://github.com/PreternaturalAI/AI/blob/main/LICENSE).





