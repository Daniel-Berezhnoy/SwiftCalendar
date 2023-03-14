//
//  SCTabView.swift
//  SwiftCalendar
//
//  Created by Daniel Berezhnoy on 3/14/23.
//

import SwiftUI

struct SCTabView: View {
    var body: some View {
        TabView {
            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
            
            StreakView()
                .tabItem { Label("Streak", systemImage: "swift") }
        }
    }
}

struct SCTabView_Previews: PreviewProvider {
    static var previews: some View {
        SCTabView()
            .environment(\.managedObjectContext,
                          PersistenceController.shared.container.viewContext)
    }
}
