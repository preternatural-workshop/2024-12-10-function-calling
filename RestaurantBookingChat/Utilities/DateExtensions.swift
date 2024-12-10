//
//  DateExtensions.swift
//  RestaurantBookingChat
//
//  Created by Natasha Murashev on 12/6/24.
//

import Foundation

extension Date {
    
    func formatWithOrdinal() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        let dayString = dateFormatter.string(from: self)
        
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: self)
        let suffix: String
        
        switch dayOfMonth {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }
        
        return "\(dayString)\(suffix)"
    }
    
    var mediumStyleDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
    
}
