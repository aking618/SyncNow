//
//  StandupDetailView.swift
//  SyncNow
//
//  Created by Ayren King on 7/15/24.
//

import ComposableArchitecture
import SwiftUI

struct StandupDetailFeature: Reducer {
    struct State: Equatable {
        @PresentationState var editStandup: StandupFormFeature.State?
        var standup: Standup
    }

    enum Action {
        case cancelEditStandupButtonTapped
        case delegate(Delegate)
        case deleteButtonTapped
        case deleteMettings(atOffsets: IndexSet)
        case editButtonTapped
        case editStandup(PresentationAction<StandupFormFeature.Action>)
        case saveStandupButtonTapped
    }

    enum Delegate {
        case standupUpdated(Standup)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelEditStandupButtonTapped:
                state.editStandup = nil
                return .none
            case .delegate:
                return .none
            case .deleteButtonTapped:
                return .none
            case .deleteMettings(atOffsets: let offsets):
                state.standup.meetings.remove(atOffsets: offsets)
                return .none
            case .editButtonTapped:
                state.editStandup = StandupFormFeature.State(standup: state.standup)
                return .none
            case .editStandup(_):
                return .none
            case .saveStandupButtonTapped:
                guard let standup = state.editStandup?.standup else { return .none }
                state.standup = standup
                state.editStandup = nil
                return .none
            }
        }
        .ifLet(\.$editStandup, action: /Action.editStandup) {
            StandupFormFeature()
        }
        .onChange(of: \.standup) { oldValue, newStandup in
            Reduce { state, action in
                .send(.delegate(.standupUpdated(newStandup)))
            }
        }
    }
}

struct StandupDetailView: View {
    let store: StoreOf<StandupDetailFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Section(header: Text("Standup Info")) {
                    NavigationLink {

                    } label: {
                        Label("Start Meeting", systemImage: "timer")
                            .font(.headline)
                    }
                    HStack {
                        Label("Length", systemImage: "clock")
                        Spacer()
                        Text(viewStore.standup.duration.formatted(.units()))
                    }
                    .accessibilityElement(children: .combine)

                    HStack {
                        Label("Theme", systemImage: "paintpalette")
                        Spacer()
                        Text(viewStore.standup.theme.name)
                            .padding(4)
                            .foregroundColor(viewStore.standup.theme.accentColor)
                            .background(viewStore.standup.theme.mainColor)
                            .cornerRadius(4)
                    }
                    .accessibilityElement(children: .combine)
                }

                if !viewStore.standup.meetings.isEmpty {
                    Section {
                        ForEach(viewStore.standup.meetings) { meeting in
                            NavigationLink {

                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(meeting.date, style: .date)
                                    Text(meeting.date, style: .time)
                                }
                            }
                        }
                        .onDelete { indices in
                            viewStore.send(.deleteMettings(atOffsets: indices))
                        }
                    }
                }

                Section(header: Text("Attendees")) {
                    ForEach(viewStore.standup.attendees) { attendee in
                        Label(attendee.name, systemImage: "person")
                    }
                }

                Section {
                    Button("Delete", role: .destructive) {
                        viewStore.send(.deleteButtonTapped)
                    }
                    .frame(maxWidth: .infinity)
                }

            }
            .navigationTitle(viewStore.standup.title)
            .toolbar {
                Button("Edit") {
                    viewStore.send(.editButtonTapped)
                }
            }
            .sheet(store: store.scope(state: \.$editStandup, action: { .editStandup($0) })) { store in
                NavigationStack {
                    StandupFormView(store: store)
                        .navigationTitle("Edit standup")
                        .toolbar {
                            ToolbarItem {
                                Button("Save") {
                                    viewStore.send(.saveStandupButtonTapped)
                                }
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    viewStore.send(.cancelEditStandupButtonTapped)
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StandupDetailView(
            store: Store(initialState: StandupDetailFeature.State(standup: .mock)) {
                StandupDetailFeature()
            }
        )
    }
}
