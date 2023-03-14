//
//  StreakView.swift
//  SwiftCalendar
//
//  Created by Daniel Berezhnoy on 3/13/23.
//

import SwiftUI

struct StreakView: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        predicate: NSPredicate(format: "(date >= %@) AND (date <= %@)",
                               Date().startOfMonth as CVarArg,
                               Date().endOfMonth as CVarArg)
    )

    private var days: FetchedResults<Day>
    
    @State private var streakValue = 0
    
    var body: some View {
        VStack {
            numberOfDays
            subtitle
        }
        .padding(.bottom, 100)
        .onAppear { streakValue = calculateStreakValue() }
    }
    
    var numberOfDays: some View {
        Text("\(streakValue)")
            .font(.system(size: 200, weight: .semibold, design: .rounded))
            .foregroundColor(streakValue > 0 ? .orange : .pink)
    }
    
    var subtitle: some View {
        Text("Current Streak")
            .font(.title2)
            .bold()
            .foregroundColor(.secondary)
    }
    
    func calculateStreakValue() -> Int {
        guard !days.isEmpty else { return 0 }
        
        var streakCount = 0
        let nonFutureDays = days.filter { $0.date!.dayInt <= Date().dayInt }
        
        for day in nonFutureDays.reversed() {
            if day.didStudy {
                streakCount += 1
                
            } else {
                if day.date!.dayInt != Date().dayInt {
                    break
                }
            }
        }
        
        return streakCount
    }
}

struct StreakView_Previews: PreviewProvider {
    static var previews: some View {
        StreakView()
    }
}
