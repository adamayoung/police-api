import Foundation

/// A Neighbourhood Priority.
public struct NeighbourhoodPriority: Equatable {

    /// An issue raised with the police.
    public var issue: String
    /// When the priority was agreed upon.
    public let issueDate: Date
    /// Action taken to address the priority.
    public var action: String?
    /// When action was last taken.
    public let actionDate: Date?

    /// Creates a new `NeighbourhoodPriority`.
    ///
    /// - Parameters:
    ///   - issue: An issue raised with the police.
    ///   - issueDate: When the priority was agreed upon.
    ///   - action: Action taken to address the priority.
    ///   - actionDate: When action was last taken.
    public init(
        issue: String,
        issueDate: Date,
        action: String? = nil,
        actionDate: Date? = nil
    ) {
        self.issue = issue
        self.issueDate = issueDate
        self.action = action
        self.actionDate = actionDate
    }

}