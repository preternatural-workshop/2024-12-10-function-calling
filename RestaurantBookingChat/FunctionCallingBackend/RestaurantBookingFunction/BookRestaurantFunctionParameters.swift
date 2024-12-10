//
//  BookRestaurantFunctionParameters.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/2/24.
//

import Foundation

/// The parameters that are passed to the `book_restaurant` function that we provide the LLM.
struct BookRestaurantFunctionParameters: Codable, Hashable, Sendable {
    var restaurantName: String?
    var reservationDate: String?
    var reservationTime: String?
    var numberOfGuests: Int?
}

extension BookRestaurantFunctionParameters {
    var formattedReservationDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale.current
        if let date = reservationDate {
            return dateFormatter.date(from: date)
        }
        return nil
    }
    
    var formattedTime: TimeOfDay? {
        if let reservationTime = reservationTime {
            return TimeOfDay(timeString: reservationTime)
        }
        return nil
    }
}
