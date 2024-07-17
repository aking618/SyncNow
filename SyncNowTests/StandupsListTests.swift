//
//  StandupsListTests.swift
//  SyncNowTests
//
//  Created by Ayren King on 7/15/24.
//

import ComposableArchitecture
import XCTest

@testable import SyncNow

@MainActor
final class StandupsListTests: XCTestCase {
    func testAddStandup() async {
        let store = TestStore(
            initialState: StandupsListFeature.State()
        ) {
            StandupsListFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }

        var standup = Standup(id: UUID(0), attendees: [Attendee(id: UUID(1))])
        await store.send(.addButtonTapped) {
            $0.addStandup = StandupFormFeature.State(
                standup: standup
            )
        }

        standup.title = "Morning Sync"
        await store.send(.addStandup(.presented(.set(\.$standup, standup)))) {
            $0.addStandup?.standup.title = "Morning Sync"
        }

        await store.send(.saveStandupButtonTapped) {
            $0.standups.append(Standup(
                id: UUID(0),
                attendees: [Attendee(id: UUID(1))],
                title: "Morning Sync"
            ))
            $0.addStandup = nil
        }
    }

    func testAddStandupNonExhaustive() async {
        let store = TestStore(
            initialState: StandupsListFeature.State()
        ) {
            StandupsListFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        store.exhaustivity = .off(showSkippedAssertions: true)

        var standup = Standup(id: UUID(0), attendees: [Attendee(id: UUID(1))])
        await store.send(.addButtonTapped)

        standup.title = "Morning Sync"
        await store.send(.addStandup(.presented(.set(\.$standup, standup))))

        await store.send(.saveStandupButtonTapped) {
            $0.standups.append(Standup(
                id: UUID(0),
                attendees: [Attendee(id: UUID(1))],
                title: "Morning Sync"
            ))
        }
    }
}
