//
//  App.swift
//  SyncNow
//
//  Created by Ayren King on 7/16/24.
//

import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {

    struct Path: Reducer {
        enum State: Equatable {
            case detail(StandupDetailFeature.State)
            case recordMeeting(RecordMeeting.State)
        }

        enum Action: Equatable  {
            case detail(StandupDetailFeature.Action)
            case recordMeeting(RecordMeeting.Action)
        }

        var body: some ReducerOf<Self> {
            Scope(state: /State.detail, action: /Action.detail) {
                StandupDetailFeature()
            }
            Scope(state: /State.recordMeeting, action: /Action.recordMeeting) {
                RecordMeeting()
            }
        }
    }

    struct State: Equatable {
        var path = StackState<Path.State>()
        var standupsList = StandupsListFeature.State()
    }

    enum Action: Equatable {
        case path(StackAction<Path.State, Path.Action>)
        case standupList(StandupsListFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(
            state: \.standupsList,
            action: /Action.standupList
        ) {
            StandupsListFeature()
        }

        Reduce { state, action in
            switch action {
            case let .path(.element(id: _, action: .detail(.delegate(action)))):
                switch action {
                case let .deleteStandup(id):
                    state.standupsList.standups.remove(id: id)
                case let .standupUpdated(standup):
                    state.standupsList.standups[id: standup.id] = standup
                }
                return .none
            case .path:
                return .none
            case .standupList:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: { .path($0) })
        ) {
            StandupListView(
                store: store.scope(
                    state: \.standupsList,
                    action: { .standupList($0) }
                )
            )
        } destination: { state in
            switch state {
            case .detail:
                CaseLet(
                    /AppFeature.Path.State.detail,
                     action: AppFeature.Path.Action.detail,
                     then: StandupDetailView.init(store:)
                )
            case .recordMeeting:
                CaseLet(
                    /AppFeature.Path.State.recordMeeting,
                     action: AppFeature.Path.Action.recordMeeting,
                     then: RecordMeetingView.init(store:)
                )
            }
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppFeature.State(standupsList: StandupsListFeature.State(standups: [.mock]))) {
        AppFeature()
    })
}
