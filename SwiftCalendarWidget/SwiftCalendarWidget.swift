//
//  SwiftCalendarWidget.swift
//  SwiftCalendarWidget
//
//  Created by Daniel Berezhnoy on 3/13/23.
//

import SwiftUI
import WidgetKit
import CoreData

struct Provider: TimelineProvider {
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    var dayFetchRequest: NSFetchRequest<Day> {
        let request = Day.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Day.date, ascending: true)]
        
        request.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)",
                                        Date().startOfCalendarWithPrefixDays as CVarArg,
                                        Date().endOfMonth as CVarArg)
        return request
    }
    
    func placeholder(in context: Context) -> CalendarEntry {
        CalendarEntry(date: Date(), days: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> ()) {
        do {
            let days = try viewContext.fetch(dayFetchRequest)
            let entry = CalendarEntry(date: Date(), days: days)
            completion(entry)
        } catch {
            print("Widget Failed to fetch days in the snapshot. \n\(error.localizedDescription)\n")
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        do {
            let days = try viewContext.fetch(dayFetchRequest)
            let entry = CalendarEntry(date: Date(), days: days)
            
            let timeline = Timeline(entries: [entry], policy: .after(Date().endOfDay))
            completion(timeline)
            
        } catch {
            print("Widget Failed to fetch days in the snapshot. \n\(error.localizedDescription)\n")
        }
    }
}

struct CalendarEntry: TimelineEntry {
    let date: Date
    let days: [Day]
}

struct SwiftCalendarWidgetEntryView : View {
    
    @Environment(\.widgetFamily) private var family
    var entry: CalendarEntry
    
    var body: some View {
//        switch family {
//            case .systemMedium:
                MediumWidgetView(entry: entry)
//                
//            case .systemSmall:
//                <#code#>
//            case .systemLarge:
//                <#code#>
//            case .systemExtraLarge:
//                <#code#>
//            case .accessoryCircular:
//                <#code#>
//            case .accessoryRectangular:
//                <#code#>
//            case .accessoryInline:
//                <#code#>
//            @unknown default:
//                <#code#>
//        }
    }
}

struct SwiftCalendarWidget: Widget {
    let kind: String = "SwiftCalendarWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SwiftCalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Swift Study Calendar")
        .description("Track days you study Swift with Streaks!")
        .supportedFamilies([.systemMedium])
    }
}

struct SwiftCalendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        SwiftCalendarWidgetEntryView(entry: CalendarEntry(date: Date(), days: []))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

// MARK: UI Components for different Widget Sizes
private struct MediumWidgetView: View {
    
    var entry: CalendarEntry
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        HStack {
            streakView
            calendar
        }
        .padding()
    }
    
    var streakView: some View {
        Link(destination: URL(string: "streak")!) {
            VStack {
                Text("\(calculateStreakValue())")
                    .font(.system(size: 70, weight: .bold, design: .rounded))
                    .foregroundColor(calculateStreakValue() > 0 ? .orange : .pink)
                
                Text("day streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    var calendar: some View {
        Link(destination: URL(string: "calendar")!) {
            VStack {
                CalendarHeader(font: .caption)
                
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(entry.days) { day in
                        
                        if day.date?.monthInt != Date().monthInt {
                            Text("")
                        } else {
                            Text(day.date!.formatted(.dateTime.day()))
                                .font(.system(size: 10, weight: .bold))
                                .fontWeight(.bold)
                                .foregroundColor(day.didStudy ? .orange : .secondary)
                                .frame(maxWidth: .infinity, minHeight: 19)
                                .background(.orange.opacity(day.didStudy ? 0.3 : 0))
                                .clipShape(Circle())
                                .overlay {
                                    if dayNumberMatches(day.date!) {
                                        Circle().stroke(.orange, lineWidth: 2)
                                    }
                                }
                        }
                    }
                }
            }
            .padding(.leading)
        }
    }
    
    func calculateStreakValue() -> Int {
        guard !entry.days.isEmpty else { return 0 }
        
        var streakCount = 0
        let nonFutureDays = entry.days.filter { $0.date!.dayInt <= Date().dayInt }
        
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
    
    func dayNumberMatches(_ date: Date) -> Bool {
        Date().formatted(.dateTime.day()) == date.formatted(.dateTime.day())
    }
}

private struct LockScreenWidget: View {
    var body: some View {
        Text("Test")
    }
}
