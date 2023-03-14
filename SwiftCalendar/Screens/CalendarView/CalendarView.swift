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
        .alert("Error", isPresented: $viewModel.showingErrorAlert) {
            Button("Ok") { viewModel.showingErrorAlert = false }
        } message: {
            Text("You can't study in the future! \nPlease select the date when you actually studied")
        }
    }
    
    var header: some View {
        CalendarHeader()
    }
    
    var dayGrid: some View {
        LazyVGrid(columns: viewModel.columns) {
            ForEach(days) { day in
                
                if day.date?.monthInt != Date().monthInt {
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
                        .onTapGesture {
                            viewModel.toggleDidStudy(for: day, context: viewContext)
                        }
                }
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
