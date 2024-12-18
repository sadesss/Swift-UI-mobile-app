//WorkTimeView.swift
import SwiftUI

struct WorkTimeView: View {
    @Binding var isTimerRunning: Bool
    @Binding var secondsToday: Int
    @Binding var secondsThisWeek: Int
    @Binding var currentWeekNumber: Int

    var body: some View {
        VStack {
            Text("Рабочее время")
                .font(.headline)
                .foregroundColor(.gray)

            HStack {
                VStack {
                    Text("За сегодня")
                        .foregroundColor(.black)
                    Text(timeString(from: secondsToday))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Text("За неделю")
                        .foregroundColor(.black)
                    Text(timeString(from: secondsThisWeek))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical)

            Button(action: {
                isTimerRunning.toggle()
            }) {
                Text(isTimerRunning ? "Остановить" : "Запустить")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
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

    private func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
