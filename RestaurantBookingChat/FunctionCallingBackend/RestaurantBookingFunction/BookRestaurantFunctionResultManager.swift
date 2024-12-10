//
//  RestaurantBookingResultManager.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/3/24.
//

import Foundation

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
