import SwiftUI

extension ContestListView {

    var filteredContests: [CFContest] {

        let typeFiltered = contests.filter { contest in
            (selectedType == "All" || contest.type == selectedType) &&
            (!ratedOnly || (contest.isRated ?? false))
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
}
