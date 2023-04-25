import Foundation
@testable import PoliceAPI

extension StopAndSearchDataModel {

    static var mock: StopAndSearchDataModel {
        StopAndSearchDataModel(
            type: .personSearch,
            didInvolvePerson: true,
            gender: .male,
            ageRange: "over 34",
            selfDefinedEthnicity: "White - English/Welsh/Scottish/Northern Irish/British",
            officerDefinedEthnicity: "White",
            legislation: "Police and Criminal Evidence Act 1984 (section 1)",
            objectOfSearch: "Offensive weapons",
            removalOfMoreThanOuterClothing: nil,
            operationName: nil,
            location: LocationDataModel(
                street: LocationDataModel.Street(
                    id: 883415,
                    name: "On or near Shopping Area"
                ),
                coordinate: CoordinateDataModel(
                    latitude: 52.63625,
                    longitude: -1.133691
                )
            ),
            outcome: "A no further action disposal",
            outcomeLinkedToObjectOfSearch: nil,
            date: DateFormatter.dateTimeWithTimeZoneOffset.date(from: "2018-06-08T13:40:00+00:00")!
        )
    }

    static var mocks: [StopAndSearchDataModel] {
        [
            .mock,
            StopAndSearchDataModel(
                type: .vehicleSearch,
                didInvolvePerson: false,
                gender: .female,
                ageRange: "40 - 50",
                selfDefinedEthnicity: "White - English/Welsh/Scottish/Northern Irish/British",
                officerDefinedEthnicity: "White",
                legislation: "Police and Criminal Evidence Act 1984 (section 1)",
                objectOfSearch: "Offensive language",
                removalOfMoreThanOuterClothing: true,
                operationName: nil,
                location: LocationDataModel(
                    street: LocationDataModel.Street(
                        id: 883415,
                        name: "On or near Shopping Area"
                    ),
                    coordinate: .mock
                ),
                outcome: "A no further action disposal",
                outcomeLinkedToObjectOfSearch: nil,
                date: DateFormatter.dateTimeWithTimeZoneOffset.date(from: "2019-01-12T02:22:00+00:00")!
            )
        ]
    }

}
