//
//  CalendarHeader.swift
//  SwiftCalendar
//
//  Created by Daniel Berezhnoy on 3/14/23.
//

import SwiftUI

struct CalendarHeader: View {
    
    let daysOfTheWeek = ["S", "M", "T", "W", "T", "F", "S"]
    var font = Font.body
    
    var body: some View {
        HStack {
            ForEach(daysOfTheWeek, id: \.self) { day in
                Text(day)
                    .font(font)
                    .fontWeight(.black)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct CalendarHeader_Previews: PreviewProvider {
    static var previews: some View {
        CalendarHeader()
    }
}
