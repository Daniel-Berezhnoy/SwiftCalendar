//
//  CalendarViewModel.swift
//  SwiftCalendar
//
//  Created by Daniel Berezhnoy on 3/12/23.
//

import SwiftUI
import CoreData

extension CalendarView {
    @MainActor class CalendarViewModel: ObservableObject {
        
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
            } catch {
                print("Error Saving CoreData Context! \n\(error.localizedDescription)")
            }
        }
    }
}
