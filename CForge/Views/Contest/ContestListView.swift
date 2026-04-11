import SwiftUI

struct ContestListView: View {

    @State var contests: [CFContest] = []
    @State var selectedPhase: String = "Upcoming"
    @State var selectedType: String = "All"
    @State var ratedOnly: Bool = false
    @State var isRefreshing: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""

    private let phases = ["Upcoming", "Active", "Finished"]

    var body: some View {
        NavigationView {
            VStack {

                Picker("Phase", selection: $selectedPhase) {
                    ForEach(phases, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {

                        ForEach(["All", "CF", "ICPC", "IOI"], id: \.self) { type in
                            Button(action: {
                                selectedType = type
                            }) {
                                Text(type)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(selectedType == type ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }

                        Button(action: {
                            ratedOnly.toggle()
                        }) {
                            Text("Rated")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(ratedOnly ? Color.green : Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }

                if isRefreshing {
                    ProgressView("Loading contests...")
                        .foregroundColor(.white)
                        .padding()
                }
                else {
                    ScrollView {
                        LazyVStack(spacing: 12) {

                            ForEach(filteredContests) { contest in
                                NavigationLink(destination: Text(contest.name)) {

                                    VStack(alignment: .leading, spacing: 10) {

                                        HStack {
                                            Text(contest.name)
                                                .font(.headline)
                                                .foregroundColor(.white)

                                            Spacer()

                                            if ["CODING", "PENDING_SYSTEM_TEST", "SYSTEM_TEST"].contains(contest.phase) {
                                                Text("LIVE")
                                                    .font(.caption)
                                                    .padding(6)
                                                    .background(Color.red)
                                                    .cornerRadius(6)
                                            }
                                        }

                                        HStack(spacing: 16) {

                                            if let start = contest.startTimeSeconds {
                                                Text(timeString(from: start))
                                                    .foregroundColor(.cyan)
                                            }

                                            Text(durationString(from: contest.durationSeconds))
                                                .foregroundColor(.cyan)
                                        }

                                        Divider().background(Color.gray)

                                        HStack {
                                            Spacer()

                                            Text("Register")
                                                .font(.caption)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.blue.opacity(0.2))
                                                .foregroundColor(.blue)
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.cyan, .blue],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(16)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                }
            }
            .navigationTitle("Contests")
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                Task {
                    await loadContests()
                }
            }
            
        }
    }

    private func timeString(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func durationString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

