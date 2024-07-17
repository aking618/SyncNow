//
//  StandupDetailTests.swift
//  SyncNowTests
//
//  Created by Ayren King on 7/16/24.
//

import ComposableArchitecture
import XCTest

@testable import SyncNow

@MainActor
final class StandupDetailTests: XCTestCase {
    func testEdit() async throws {
        var standup = Standup.mock
        let store = TestStore(initialState: StandupDetailFeature.State(standup: standup)) {
            StandupDetailFeature()
        }
        store.exhaustivity = .off

        await store.send(.editButtonTapped)
        standup.title = "Morning Sync"
        await store.send(.editStandup(.presented(.set(\.$standup, standup))))
        await store.send(.saveStandupButtonTapped) {
            $0.standup.title = "Morning Sync"
        }
    }
}
