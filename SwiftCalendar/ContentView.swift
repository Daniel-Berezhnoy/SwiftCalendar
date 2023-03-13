//
//  ContentView.swift
//  SwiftCalendar
//
//  Created by Daniel Berezhnoy on 3/12/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Day.date, ascending: true)],
        animation: .default
    )
    
    private var days: FetchedResults<Day>

    var body: some View {
        NavigationView {
            List {
                ForEach(days) { day in
                    Text(day.date!.formatted())
                }
            }
            .navigationTitle("Swift Calendar")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
