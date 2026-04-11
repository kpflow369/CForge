import SwiftUI

struct ContestListView: View {

    @State private var contests: [CFContest] = []
    @State private var selectedPhase = "Upcoming"
    @State private var selectedType = "All"
    @State private var ratedOnly = false
    @State private var isRefreshing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var searchText = ""

    private let phases = ["Upcoming", "Active", "Finished"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                //Phase selector
                Picker("Phase", selection: $selectedPhase) {
                    ForEach(phases, id: \.self) { Text($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ContestSearchBar(text: $searchText, placeholder: "Search contests...")
                    .padding(.horizontal)

                // Type filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(["All", "CF", "ICPC", "IOI"], id: \.self) { type in
                            Button {
                                selectedType = type
                            } label: {
                                Text(type)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedType == type
                                        ? Color.blue
                                        : Color.gray.opacity(0.3)
                                    )
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                //Contest list
                if isRefreshing {
                    ProgressView()
                        .padding(.top, 20)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredContests) { contest in
                                NavigationLink {
                                    ContestDetailView(contest: contest)
                                } label: {
                                    ContestCardView(contest: contest)
                                }
                            }
                        }
                        .padding(.top, 5)
                    }
                    .refreshable {
                        await loadContests()
                    }
                }
            }
            .navigationTitle("Contests")

            // Error alert
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }

            .onAppear {
                Task { await loadContests() }
            }
        }
    }

    // MARK: - Filtering Logic

    var filteredContests: [CFContest] {
        contests.filter { contest in
            
            // Phase filter
            let matchesPhase =
                (selectedPhase == "Upcoming" && contest.phase == "BEFORE") ||
                (selectedPhase == "Active" && contest.phase == "CODING") ||
                (selectedPhase == "Finished" && contest.phase == "FINISHED")

            //FIXED: Case-insensitive type match
            let matchesType =
                selectedType == "All" ||
                contest.name.lowercased().contains(selectedType.lowercased())

            // Search filter
            let matchesSearch =
                searchText.isEmpty ||
                contest.name.lowercased().contains(searchText.lowercased())

            return matchesPhase && matchesType && matchesSearch
        }
    }

    // MARK: - API

    func loadContests() async {
        isRefreshing = true
        do {
            contests = try await fetchContests()
        } catch {
            handleError(error)
        }
        isRefreshing = false
    }

    func fetchContests() async throws -> [CFContest] {
        let url = URL(string: "https://codeforces.com/api/contest.list")!
        let (data, _) = try await URLSession.shared.data(from: url)

        let response = try JSONDecoder().decode(ContestResponse.self, from: data)

        guard response.status == "OK" else {
            throw NSError(domain: "", code: 0, userInfo: [
                NSLocalizedDescriptionKey: response.comment ?? "Unknown error"
            ])
        }

        return response.result ?? []
    }

    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
