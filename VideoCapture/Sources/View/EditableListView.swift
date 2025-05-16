//
//  EditableListView.swift
//  VideoCapture
//
//  Created by Bhavik Goyal on 13/05/25.
//

import SwiftUI

struct EditableListView<T: Identifiable>: View where T: Equatable {
    @Binding var items: [T]
    var constantCount: Int
    var getName: (T) -> String
    var setName: (T, String) -> T
    var onAdd: () -> Void
    var onRemove: (Int) -> Void
    var onSelect: ((Int?) -> Void)? = nil

    @State private var selectedIndex: Int? = nil
    @State private var editingIndex: Int? = nil

    func editingBinding(index: Int) -> Binding<Bool> {
        Binding(
            get: { editingIndex == index },
            set: { _ in }
        )
    }

    func getTextBinding(index: Int) -> Binding<String> {
        Binding(
            get: { getName(items[index]) },
            set: { newValue in
                items[index] = setName(items[index], newValue)
            }
        )
    }

    var body: some View {
        VStack(spacing: 5) {
            List(items.indices, id: \.self, selection: $selectedIndex) { index in
                Group {
                    if editingIndex == index, index >= constantCount {
                        InputField(isFocused: editingBinding(index: index), text: getTextBinding(index: index))
                            .frame(height: 20)
                    } else {
                        Text(getName(items[index]))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedIndex == index {
                                    editingIndex = index
                                } else {
                                    selectedIndex = index
                                    editingIndex = nil
                                }
                                onSelect?(selectedIndex)
                            }
                    }
                }
                .padding(0)
                .frame(height: 20)
                .listRowSeparator(.hidden)
            }
            .listStyle(.bordered)
            .frame(maxHeight: 100)

            AddRemoveButton(
                selectedIndex: $selectedIndex,
                editingIndex: $editingIndex,
                onAdd: { onAdd() },
                onRemove: {
                    if let index = selectedIndex {
                        onRemove(index)
                        if index == editingIndex { editingIndex = nil }
                        selectedIndex = nil
                        onSelect?(nil)
                    }
                }
            )
            .padding(.leading, 5)
        }
    }
}
