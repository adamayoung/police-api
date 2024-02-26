//
//  NeighbourhoodPolicingTeam.swift
//  PoliceDataKit
//
//  Copyright © 2024 Adam Young.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an AS IS BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

///
/// A model representing a neighbourhood police team.
///
public struct NeighbourhoodPolicingTeam: Equatable, Codable {

    /// Unique force identifier.
    public let force: String

    /// Force specific team identifier.
    public let neighbourhood: String

    ///
    /// Creates a neighbourhood police team object.
    ///
    /// - Parameters:
    ///   - force: Unique force identifier.
    ///   - neighbourhood: Force specific team identifier.
    ///
    public init(force: String, neighbourhood: String) {
        self.force = force
        self.neighbourhood = neighbourhood
    }

}
