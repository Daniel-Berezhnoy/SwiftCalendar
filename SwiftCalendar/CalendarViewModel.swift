//
//  CalendarViewModel.swift
//  SwiftCalendar
//
//  Created by Daniel Berezhnoy on 3/12/23.
//

import SwiftUI
import CoreData

@MainActor class CalendarViewModel: ObservableObject {
    
    let daysOfTheWeek = ["S", "M", "T", "W", "T", "F", "S",]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var currentMonthName: String {
        Date().monthFullName
    }
    
    func dayNumberMatches(_ date: Date) -> Bool {
        Date().formatted(.dateTime.day()) == date.formatted(.dateTime.day())
    }
    
    func createMonthDays(for date: Date, context: NSManagedObjectContext) {
        for dayOffset in 0 ..< date.numberOfDaysInMonth {
            let newDay = Day(context: context)
            newDay.date = Calendar.current.date(byAdding: .day, value: dayOffset, to: date.startOfMonth)
            newDay.didStudy = false
        }
        
        do {
            try context.save()
            print("✅ \(date.monthFullName) days created")
        } catch {
            print("Error Saving CoreData Context! \n\(error.localizedDescription)")
        }
    }
}
