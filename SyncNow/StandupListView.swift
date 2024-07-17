//
//  StandupListView.swift
//  SyncNow
//
//  Created by Ayren King on 7/12/24.
//

import ComposableArchitecture
import SwiftUI

struct StandupsListFeature: Reducer {
    struct State: Equatable {
        @PresentationState var addStandup: StandupFormFeature.State?
        var standups: IdentifiedArrayOf<Standup> = []
    }

    @CasePathable
    enum Action {
        case addButtonTapped
        case addStandup(PresentationAction<StandupFormFeature.Action>)
        case cancelStandupButtonTapped
        case saveStandupButtonTapped
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.addStandup = StandupFormFeature.State(standup: Standup(id: uuid()))
                return .none

            case .addStandup:
                return .none

            case .cancelStandupButtonTapped:
                state.addStandup = nil
                return .none

            case .saveStandupButtonTapped:
                guard let standup = state.addStandup?.standup else { return .none }
                state.standups.append(standup)
                state.addStandup = nil
                return .none
            }
        }
        .ifLet(\.$addStandup, action: /Action.addStandup ) {
            StandupFormFeature()
        }

    }
}

struct StandupListView: View {
    let store: StoreOf<StandupsListFeature>

    var body: some View {
        WithViewStore(store, observe: \.standups) { viewStore in
            List {
                ForEach(viewStore.state) { standup in
                    NavigationLink(
                        state: AppFeature.Path.State.detail(StandupDetailFeature.State(standup: standup))
                    ) {
                        CardView(standup: standup)
                    }
                    .listRowBackground(standup.theme.mainColor)
                }
            }
            .navigationTitle("Daily Standups")
            .toolbar {
                ToolbarItem {
                    Button("Add") {
                        viewStore.send(.addButtonTapped)
                    }
                }
            }
            .sheet(
                store: store.scope(
                    state: \.$addStandup,
                    action: { .addStandup($0) }
                )
            ) { store in
                NavigationStack {
                    StandupFormView(store: store)
                        .navigationTitle("New standup")
                        .toolbar {
                            ToolbarItem {
                                Button("Save") {
                                    viewStore.send(.saveStandupButtonTapped)
                                }
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    viewStore.send(.cancelStandupButtonTapped)
                                }
                            }
                        }
                }
            }
        }
    }
}

struct CardView: View {
    let standup: Standup
    var body: some View {
        VStack(alignment: .leading) {
            Text(standup.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            HStack {
                Label("\(standup.attendees.count)", systemImage: "person.3")
                    .accessibilityLabel("\(standup.attendees.count) attendees")
                Spacer()
                Label("\(standup.duration.formatted(.units()))", systemImage: "clock")
                    .accessibilityLabel("\(standup.duration) minute meeting")
                    .labelStyle(.titleAndIcon)
            }
            .font(.caption)
        }
        .padding()
        .foregroundColor(standup.theme.accentColor)
    }
}


#Preview {
    MainActor.assumeIsolated {
        NavigationStack {
            StandupListView(
                store: Store(initialState: StandupsListFeature.State(standups: [.mock])) {
                    StandupsListFeature()
                }
            )
        }
    }
}
