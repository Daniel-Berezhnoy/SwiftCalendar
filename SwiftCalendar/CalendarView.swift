//
//  CalendarView.swift
//  SwiftCalendar
//
//  Created by Daniel Berezhnoy on 3/12/23.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    
    @StateObject private var viewModel = CalendarViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)])
    
    private var days: FetchedResults<Day>
    let daysOfTheWeek = ["S", "M", "T", "W", "T", "F", "S",]
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        NavigationView {
            VStack {
                header
                dayGrid
                Spacer()
            }
            .navigationTitle(viewModel.currentMonthName)
            .padding()
        }
    }
    
    var header: some View {
        HStack {
            ForEach(daysOfTheWeek, id: \.self) { day in
                Text(day)
                    .fontWeight(.black)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    var dayGrid: some View {
        LazyVGrid(columns: columns) {
            ForEach(days) { day in
                ZStack {
                    Text(day.date!.formatted(.dateTime.day()))
                        .fontWeight(.bold)
                        .foregroundColor(day.didStudy ? .orange : .secondary)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(.orange.opacity(day.didStudy ? 0.3 : 0))
                        .clipShape(Circle())
                    
                    if viewModel.dayNumberMatches(day.date!) {
                        Circle().stroke(.orange, lineWidth: 4.5)
                    }
                }
            }
        }
    }
    
    func createMonthDays(for date: Date) {
        for dayOffset in 0 ..< date.numberOfDaysInMonth {
            let newDay = Day(context: viewContext)
            newDay.date = Calendar.current.date(byAdding: .day, value: dayOffset, to: date.startOfMonth)
            newDay.didStudy = false
        }
        
        do {
            try viewContext.save()
            print("✅ \(date.monthFullName) days created!")
        } catch {
            print("Error Saving CoreData Context! \n\(error.localizedDescription)")
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
