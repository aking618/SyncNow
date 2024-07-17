//
//  StandupForm.swift
//  SyncNow
//
//  Created by Ayren King on 7/15/24.
//

import ComposableArchitecture
import SwiftUI

struct StandupFormFeature: Reducer {
    struct State: Equatable {
        @BindingState var focus: Field?
        @BindingState var standup: Standup

        enum Field: Hashable {
            case attendee(Attendee.ID)
            case title
        }

        init(focus: Field? = .title, standup: Standup) {
            self.focus = focus
            self.standup = standup
            if self.standup.attendees.isEmpty {
                @Dependency(\.uuid) var uuid
                self.standup.attendees.append(Attendee(id: uuid()))
            }
        }
    }

    enum Action: BindableAction {
        case addAttendeeButtonTapped
        case binding(BindingAction<State>)
        case deleteAttendess(atOffsets: IndexSet)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addAttendeeButtonTapped:
                let attendee = Attendee(id: self.uuid())
                state.standup.attendees.append(attendee)
                state.focus = .attendee(attendee.id)
                return .none

            case .binding(_):
                return .none

            case .deleteAttendess(let offsets):
                state.standup.attendees.remove(atOffsets: offsets)
                if state.standup.attendees.isEmpty {
                    state.standup.attendees.append(Attendee(id: self.uuid()))
                }

                guard let firstIndex = offsets.first else { return .none }
                let index = min(firstIndex, state.standup.attendees.count - 1)
                state.focus = .attendee(state.standup.attendees[index].id)
                return .none
            }
        }
    }
}

struct StandupFormView: View {
    let store: StoreOf<StandupFormFeature>
    @FocusState var focus: StandupFormFeature.State.Field?

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    TextField("Title", text: viewStore.$standup.title)
                        .focused($focus, equals: .title)

                    HStack {
                        Slider(value: viewStore.$standup.duration.minutes, in: 5...30, step: 1) {
                            Text("Length")
                        }
                        Spacer()
                        Text(viewStore.standup.duration.formatted(.units()))
                    }

                    ThemePicker(selection: viewStore.$standup.theme)
                } header: {
                    Text("Standup Info")
                }

                Section {
                    ForEach(viewStore.$standup.attendees) { $attendee in
                        TextField("Name", text: $attendee.name)
                            .focused($focus, equals: .attendee(attendee.id))
                    }
                    .onDelete { indeces in
                        viewStore.send(.deleteAttendess(atOffsets: indeces))
                    }

                    Button("Add attendee") {
                        viewStore.send(.addAttendeeButtonTapped)
                    }
                } header: {
                    Text("Attendees")
                }
            }
            .bind(viewStore.$focus, to: $focus)
        }
    }
}

extension Duration {
    fileprivate var minutes: Double {
        get { Double(components.seconds / 60) }
        set { self = .seconds(newValue * 60) }
    }
}

struct ThemePicker: View {
  @Binding var selection: Theme

  var body: some View {
    Picker("Theme", selection: self.$selection) {
      ForEach(Theme.allCases) { theme in
        ZStack {
          RoundedRectangle(cornerRadius: 4)
            .fill(theme.mainColor)
          Label(theme.name, systemImage: "paintpalette")
            .padding(4)
        }
        .foregroundColor(theme.accentColor)
        .fixedSize(horizontal: false, vertical: true)
        .tag(theme)
      }
    }
  }
}


#Preview {
    StandupFormView(
        store: Store(initialState: StandupFormFeature.State(standup: .mock), reducer: {
            StandupFormFeature()
        })
    )
}
