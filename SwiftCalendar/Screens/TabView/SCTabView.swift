//
//  SCTabView.swift
//  SwiftCalendar
//
//  Created by Daniel Berezhnoy on 3/14/23.
//

import SwiftUI

struct SCTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
                .tag(0)
            
            StreakView()
                .tabItem { Label("Streak", systemImage: "swift") }
                .tag(1)
        }
        .onOpenURL { url in selectedTab = url.absoluteString == "calendar" ? 0 : 1 }
    }
}

struct SCTabView_Previews: PreviewProvider {
    static var previews: some View {
        SCTabView()
            .environment(\.managedObjectContext,
                          PersistenceController.shared.container.viewContext)
    }
}
