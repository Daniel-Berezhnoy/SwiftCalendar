//
//  SwiftCalendarWidget.swift
//  SwiftCalendarWidget
//
//  Created by Daniel Berezhnoy on 3/13/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct SwiftCalendarWidgetEntryView : View {
    
    var entry: Provider.Entry
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        HStack {
            streakView
            calendar
        }
        .padding()
    }
    
    var streakView: some View {
        VStack {
            Text("\(30)")
                .font(.system(size: 70, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
            
            Text("day streak")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    var calendar: some View {
        VStack {
            CalendarHeader(font: .caption)
            
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(0 ..< 31) { day in
                    
                    Text("\(day)")
                        .font(.system(size: 10, weight: .bold))
                        .fontWeight(.bold)
                        .foregroundColor(.black.opacity(0.7))
                        .frame(maxWidth: .infinity, minHeight: 19)
                        .background(.orange.opacity(0.3))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.leading)
    }
}

struct SwiftCalendarWidget: Widget {
    let kind: String = "SwiftCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SwiftCalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}

struct SwiftCalendarWidget_Previews: PreviewProvider {
    static var previews: some View {
        SwiftCalendarWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
