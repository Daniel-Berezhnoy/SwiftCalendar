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
        switch family {
            case .systemMedium:
                MediumWidgetView(entry: entry, streakValue: streakValue)
                
            case .accessoryCircular:
                LockScreenCircularView(entry: entry)
                
            case .accessoryRectangular:
                LockScreenRectangularView(entry: entry)
                
            case .accessoryInline:
                LockScreenInlineView(streakValue: streakValue)
                
            case .systemSmall, .systemLarge, .systemExtraLarge:
                EmptyView()
                
            @unknown default:
                EmptyView()
        }
    }
    
    var streakValue: Int {
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
}

struct SwiftCalendarWidget: Widget {
    let kind: String = "SwiftCalendarWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SwiftCalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Swift Study Calendar")
        .description("Track the days you study Swift with Streaks!")
        .supportedFamilies([.systemMedium,
                            .accessoryCircular,
                            .accessoryRectangular,
                            .accessoryInline])
    }
}

struct SwiftCalendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        SwiftCalendarWidgetEntryView(entry: CalendarEntry(date: Date(), days: []))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        SwiftCalendarWidgetEntryView(entry: CalendarEntry(date: Date(), days: []))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        
        SwiftCalendarWidgetEntryView(entry: CalendarEntry(date: Date(), days: []))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        
        SwiftCalendarWidgetEntryView(entry: CalendarEntry(date: Date(), days: []))
            .previewContext(WidgetPreviewContext(family: .accessoryInline))
    }
}

// MARK: UI Components for different Widget Sizes
private struct MediumWidgetView: View {
    
    var entry: CalendarEntry
    let streakValue: Int
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
                Text("\(streakValue)")
                    .font(.system(size: 70, weight: .bold, design: .rounded))
                    .foregroundColor(streakValue > 0 ? .orange : .pink)
                
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
    
    func dayNumberMatches(_ date: Date) -> Bool {
        Date().formatted(.dateTime.day()) == date.formatted(.dateTime.day())
    }
}

private struct LockScreenCircularView: View {
    var entry: CalendarEntry
    
    var body: some View {
        Gauge(value: daysStudied, in: 0 ... currentCalendarDays) {
            Image(systemName: "swift")
            
        } currentValueLabel: {
            Text("\(daysStudied, format: .number)")
        }
        .gaugeStyle(.accessoryCircular)
        .widgetURL(URL(string: "calendar"))
    }
    
    var currentCalendarDays: Double {
        let numberOfDays = entry.days.filter { $0.date?.monthInt == Date().monthInt }.count
        return Double(numberOfDays)
    }
    
    var daysStudied: Double {
        let numberOfDays = entry.days
            .filter { $0.date?.monthInt == Date().monthInt }
            .filter { $0.didStudy }
            .count
        return Double(numberOfDays)
    }
}

private struct LockScreenRectangularView: View {
    
    var entry: CalendarEntry
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(entry.days) { day in
                
                if day.date?.monthInt != Date().monthInt {
                    Text(" ")
                        .font(.system(size: 7))
                        .frame(maxWidth: .infinity)
                    
                } else {
                    if day.didStudy {
                        Image(systemName: "swift")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 7, height: 7)
                        
                    } else {
                        Text(day.date!.formatted(.dateTime.day()))
                            .font(.system(size: 7))
                            .frame(maxWidth: .infinity)
                            .bold(dayNumberMatches(day.date!))
                    }
                }
            }
        }
        .padding()
        .widgetURL(URL(string: "calendar"))
    }
    
    func dayNumberMatches(_ date: Date) -> Bool {
        Date().formatted(.dateTime.day()) == date.formatted(.dateTime.day())
    }
}

private struct LockScreenInlineView: View {
    let streakValue: Int
    
    var body: some View {
        Label("Streak - \(streakValue) days", systemImage: "swift")
            .widgetURL(URL(string: "streak"))
    }
}
