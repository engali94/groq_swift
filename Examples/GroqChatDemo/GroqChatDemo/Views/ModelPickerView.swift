//
//  ModelPickerView.swift
//  GroqChatDemo
//
//  Created by Ali Hilal on 23/02/2025.
//

import SwiftUI

struct ModelPickerView: View {
    @Binding var selectedModel: GroqModel
    @State private var showModelDetails = false

    var body: some View {
        Menu {
            Button {
                showModelDetails = true
            } label: {
                Label("View All Models", systemImage: "list.bullet.rectangle.portrait")
            }

            Divider()

            Section("Production Models") {
                ForEach(GroqModel.productionModels) { model in
                    modelButton(for: model)
                }
            }

            Section("Preview Models") {
                ForEach(GroqModel.previewModels) { model in
                    modelButton(for: model)
                }
            }
        } label: {
            Label(selectedModel.name, systemImage: selectedModel.icon)
                .lineLimit(1)
        }
        .sheet(isPresented: $showModelDetails) {
            NavigationStack {
                List {
                    Section("Production Models") {
                        ForEach(GroqModel.productionModels) { model in
                            modelRow(for: model)
                        }
                    }

                    Section {
                        ForEach(GroqModel.previewModels) { model in
                            modelRow(for: model)
                        }
                    } header: {
                        Text("Preview Models")
                    } footer: {
                        Text("Preview models are intended for evaluation purposes only and should not be used in production environments.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .navigationTitle("Available Models")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showModelDetails = false
                        }
                    }
                }
            }
        }
    }

    private func modelButton(for model: GroqModel) -> some View {
        Button {
            selectedModel = model
        } label: {
            HStack {
                Label(model.name, systemImage: model.icon)
                if let context = model.contextWindow {
                    Spacer()
                    Text("\(context/1000)K")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
    }

    private func modelRow(for model: GroqModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: model.icon)
                        .foregroundStyle(model == selectedModel ? .blue : .secondary)
                    Text(model.name)
                        .font(.headline)
                }

                if let context = model.contextWindow {
                    Text("Context: \(context/1000)K tokens")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if model == selectedModel {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedModel = model
            showModelDetails = false
        }
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9)
                .combined(with: .opacity)
                .combined(with: .offset(y: 20)),
            removal: .scale(scale: 0.8)
                .combined(with: .opacity)
        )
    }
}
