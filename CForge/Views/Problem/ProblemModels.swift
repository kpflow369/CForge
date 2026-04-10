import Foundation
import SwiftUI


struct Problem: Identifiable, Codable, Hashable {
    let id: String
    let contestId: Int
    let index: String
    let title: String
    let rating: Int?
    let tags: [String]
}

struct ProblemsResponse: Codable {
    let status: String
    let result: ProblemsResult?
    let comment: String?
}

struct ProblemsResult: Codable {
    let problems: [ApiProblem]
    let problemStatistics: [ProblemStatistic]
}

struct ApiProblem: Codable {
    let contestId: Int?
    let index: String?
    let name: String?
    let rating: Int?
    let tags: [String]?
}

struct ProblemStatistic: Codable {
    let contestId: Int?
    let index: String?
    let solvedCount: Int?
}

struct Submission: Codable, Identifiable {
    let id: Int
    let contestId: Int?
    let creationTimeSeconds: Int
    let relativeTimeSeconds: Int
    let problem: ApiProblem
    let author: Author
    let programmingLanguage: String
    let verdict: Verdict?
    let testset: String
    let passedTestCount: Int
    let timeConsumedMillis: Int
    let memoryConsumedBytes: Int
    
    var verdictColor: Color {
        verdict?.color ?? .gray
    }
    
    var formattedTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(creationTimeSeconds))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct Author: Codable {
    let contestId: Int?
    let members: [Member]
    let participantType: String
    let ghost: Bool
    let room: Int?
    let startTimeSeconds: Int?
}

struct Member: Codable {
    let handle: String
}

enum Verdict: String, Codable {
    case failed = "FAILED"
    case ok = "OK"
    case partial = "PARTIAL"
    case compilationError = "COMPILATION_ERROR"
    case runtimeError = "RUNTIME_ERROR"
    case wrongAnswer = "WRONG_ANSWER"
    case presentationError = "PRESENTATION_ERROR"
    case timeLimitExceeded = "TIME_LIMIT_EXCEEDED"
    case memoryLimitExceeded = "MEMORY_LIMIT_EXCEEDED"
    case idlenessLimitExceeded = "IDLENESS_LIMIT_EXCEEDED"
    case securityViolated = "SECURITY_VIOLATED"
    case crashed = "CRASHED"
    case inputPreparationCrashed = "INPUT_PREPARATION_CRASHED"
    case challenged = "CHALLENGED"
    case skipped = "SKIPPED"
    case testing = "TESTING"
    case rejected = "REJECTED"
    
    var displayName: String {
        switch self {
        case .ok: return "Accepted"
        case .wrongAnswer: return "Wrong Answer"
        case .timeLimitExceeded: return "Time Limit Exceeded"
        case .memoryLimitExceeded: return "Memory Limit Exceeded"
        case .compilationError: return "Compilation Error"
        case .runtimeError: return "Runtime Error"
        default: return rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
    
    var color: Color {
        switch self {
        case .ok: return .neonGreen
        case .wrongAnswer, .compilationError, .runtimeError: return .neonPink
        case .timeLimitExceeded, .memoryLimitExceeded: return .orange
        case .testing, .skipped: return .gray
        case .partial: return .yellow
        default: return .primary
        }
    }
}

struct ContestSubmissionsResponse: Codable {
    let status: String
    let result: [Submission]?
    let comment: String?
}



