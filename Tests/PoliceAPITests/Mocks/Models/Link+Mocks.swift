import Foundation
import PoliceAPI

extension Link {

    static var mock: Link {
        Link(
            title: "Leicester City Council",
            description: "Leicester City Council description",
            url: URL(string: "http://www.leicester.gov.uk/")
        )
    }

    static var mockNoDescription: Link {
        Link(
            title: "Leicester City Council",
            url: URL(string: "http://www.leicester.gov.uk/")
        )
    }

    static var mockNilURL: Link {
        Link(
            title: "YourCommunityAlerts.co.uk",
            description: "Your Community Alerts",
            url: nil
        )
    }

}
