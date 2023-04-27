import Foundation

struct PoliceForceReferenceDataModel: Identifiable, Decodable, Equatable {

    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

}
