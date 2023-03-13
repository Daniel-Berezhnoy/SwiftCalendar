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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        predicate: NSPredicate(format: "(date >= %@) AND (date <= %@)",
                               Date().startOfCalendarWithPrefixDays as CVarArg,
                               Date().endOfMonth as CVarArg)
    )
    
    private var days: FetchedResults<Day>
    
    var body: some View {
        NavigationView {
            VStack {
                header
                dayGrid
                Spacer()
            }
            .padding()
            .navigationTitle(viewModel.currentMonthName)
            .onAppear { createCalendar() }
        }
    }
    
    var header: some View {
        HStack {
            ForEach(viewModel.daysOfTheWeek, id: \.self) { day in
                Text(day)
                    .fontWeight(.black)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    var dayGrid: some View {
        LazyVGrid(columns: viewModel.columns) {
            ForEach(days) { day in
                DayLabel(for: day)
            }
        }
    }
    
    func createCalendar() {
        if days.isEmpty {
            viewModel.createMonthDays(for: .now.startOfPreviousMonth, context: viewContext)
            viewModel.createMonthDays(for: .now, context: viewContext)
            
        } else if days.count < 10 {
            viewModel.createMonthDays(for: .now, context: viewContext)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct DayLabel: View {
    
    @StateObject private var viewModel = CalendarViewModel()
    let day: FetchedResults<Day>.Element
    
    var body: some View {
        if isPreviousMonth {
            Text("")
            
        } else {
            Text(day.date!.formatted(.dateTime.day()))
                .fontWeight(.bold)
                .foregroundColor(day.didStudy ? .orange : .secondary)
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(.orange.opacity(day.didStudy ? 0.3 : 0))
                .clipShape(Circle())
                .overlay {
                    if viewModel.dayNumberMatches(day.date!) {
                        Circle().stroke(.orange, lineWidth: 4)
                    }
                }
        }
    }
    
    var isPreviousMonth: Bool {
        day.date?.monthInt != Date().monthInt
    }
    
    init(for day: FetchedResults<Day>.Element) {
        self.day = day
    }
}
