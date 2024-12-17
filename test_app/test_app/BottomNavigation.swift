import SwiftUI

struct BottomNavigation: View {
    @Binding var tasks: [Date: [Task]]

    var body: some View {
        HStack {
            NavigationLink(destination: AddTaskView(tasks: $tasks)) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.pink)
                    .font(.largeTitle)
            }

            Spacer()

            NavigationLink(destination: CalendarView(tasks: $tasks)) {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(.pink)
                    .font(.largeTitle)
            }
        }
        .padding()
        .background(Color.pink.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}
