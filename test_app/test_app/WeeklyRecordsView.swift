//WeeklyRedords.swift
import SwiftUI

struct WeeklyRecordsView: View {
    @Binding var dailyRecords: [DailyWorkRecord]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Время, отработанное за неделю")
                .font(.headline)
                .foregroundColor(.black)

            if dailyRecords.isEmpty {
                Text("Нет отработанного времени за неделю.")
                    .foregroundColor(.gray)
            } else {
                ForEach(dailyRecords) { record in
                    HStack {
                        Text(formattedDate(record.date))
                        Spacer()
                        Text(timeString(from: record.secondsWorked))
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
        )
        .padding(.horizontal)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }

    func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
