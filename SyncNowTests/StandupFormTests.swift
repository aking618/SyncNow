//
//  StandupFormTests.swift
//  SyncNowTests
//
//  Created by Ayren King on 7/15/24.
//

import ComposableArchitecture
import XCTest

@testable import SyncNow

@MainActor
final class StandupFormTests: XCTestCase {
    func testAddDeleteAttendee() async {
        let store = TestStore(
            initialState: StandupFormFeature.State(
                standup: Standup(id: UUID(), attendees: [Attendee(id: UUID())])
            )
        ) {
            StandupFormFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        await store.send(.addAttendeeButtonTapped) {
            $0.focus = .attendee(UUID(0))
            $0.standup.attendees.append(
                Attendee(id: UUID(0))
            )
        }

        await store.send(.deleteAttendess(atOffsets: [1])) {
            $0.focus = .attendee($0.standup.attendees[0].id)
            $0.standup.attendees.remove(at: 1)
        }
    }
}
