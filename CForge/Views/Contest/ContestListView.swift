import SwiftUI

struct ContestListView: View {

    @State var contests: [CFContest] = []
    @State var searchText: String = ""
    @State var selectedPhase: String = "Upcoming"
    @State var selectedType: String = "All"
    @State var ratedOnly: Bool = false
    @State var isRefreshing: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""

    private let phases = ["Upcoming", "Active", "Finished"]
    private let types = ["All", "CF", "ICPC", "IOI"]

    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Contests")
                .onAppear {
                    Task { await loadContests() }
                }
        }
    }

    private var filteredContests: [CFContest] {
        let searched = contests.filter {
            searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased())
        }

        let typeFiltered = searched.filter { contest in
            (selectedType == "All" || contest.type == selectedType) &&
            (!ratedOnly || (contest.isRated))
        }

        switch selectedPhase {
        case "Upcoming":
            return typeFiltered.filter { $0.phase == "BEFORE" }

        case "Active":
            return typeFiltered.filter {
                ["CODING", "PENDING_SYSTEM_TEST", "SYSTEM_TEST"].contains($0.phase)
            }

        case "Finished":
            return typeFiltered
                .filter { $0.phase == "FINISHED" }
                .sorted { ($0.startTimeSeconds ?? 0) > ($1.startTimeSeconds ?? 0) }
                .prefix(50)
                .map { $0 }

        default:
            return typeFiltered
        }
    }

    private var contentView: some View {
        VStack {

            Picker("Phase", selection: $selectedPhase) {
                ForEach(phases, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(types, id: \.self) { type in
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

            TextField("Search contests...", text: $searchText)
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()

            ScrollView {
                LazyVStack {

                    if filteredContests.isEmpty {
                        Text("No contests available")
                            .foregroundColor(.gray)
                            .padding()
                    }

                    ForEach(filteredContests) { contest in
                        NavigationLink(destination: Text(contest.name)) {

                            VStack(alignment: .leading, spacing: 8) {

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

                                Text("Type: \(contest.type)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

