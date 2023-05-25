import Foundation

///
/// The gender of a person.
///
public enum Gender: String, CaseIterable, CustomStringConvertible, Codable {

    /// Male.
    case male = "Male"

    /// Female.
    case female = "Female"

    /// Other.
    case other = "Other"

    /// The localized string describing the gender.
    public var description: String {
        switch self {
        case .male:
            return NSLocalizedString("MALE", bundle: .module, comment: "Male")

        case .female:
            return NSLocalizedString("FEMALE", bundle: .module, comment: "Female")

        case .other:
            return NSLocalizedString("OTHER", bundle: .module, comment: "Other")
        }
    }
}
