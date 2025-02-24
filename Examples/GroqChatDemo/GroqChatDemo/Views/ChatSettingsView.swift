//
//  ChatSettingsView.swift
//  GroqChatDemo
//
//  Created by Ali Hilal on 23/02/2025.
//

import SwiftUI
import GroqSwift

struct ChatSettingsView: View {
    @Binding var settings: ChatSettings
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Stream Responses", isOn: $settings.stream)
                    if settings.stream {
                        Toggle("Intermediate Responses", isOn: Binding(
                            get: { settings.streamOptions?.intermediateResponses ?? true },
                            set: { newValue in
                                settings.streamOptions = ChatCompletionRequest.StreamOptions(
                                    intermediateResponses: newValue
                                )
                            }
                        ))
                    }
                    Text("Stream responses as they become available. Intermediate responses show partial completions.")
                }
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Temperature")
                            Spacer()
                            Text(String(format: "%.1f", settings.temperature))
                        }
                        Slider(
                            value: $settings.temperature,
                            in: 0...2,
                            step: 0.1
                        )
                    }
                    Text("What sampling temperature to use. Higher values make the output more random, lower values make it more focused.")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Top P")
                            Spacer()
                            Text(String(format: "%.1f", settings.topP))
                        }
                        Slider(value: $settings.topP, in: 0...1, step: 0.1)
                    }
                    Text("An alternative to sampling with temperature, called nucleus sampling. Only tokens with top_p probability mass are considered.")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Frequency Penalty")
                            Spacer()
                            Text(String(format: "%.1f", settings.frequencyPenalty))
                        }
                        Slider(value: $settings.frequencyPenalty, in: -2...2, step: 0.1)
                        
                        HStack {
                            Text("Presence Penalty")
                            Spacer()
                            Text(String(format: "%.1f", settings.presencePenalty))
                        }
                        Slider(value: $settings.presencePenalty, in: -2...2, step: 0.1)
                    }
                    Text("Positive values penalize new tokens based on their existing frequency in the text, decreasing the model's likelihood to repeat the same line.")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Limit Response Length", isOn: .init(
                            get: { settings.maxCompletionTokens != nil },
                            set: { if $0 { settings.maxCompletionTokens = 100 } else { settings.maxCompletionTokens = nil } }
                        ))
                        
                        if settings.maxCompletionTokens != nil {
                            HStack {
                                Text("Max Tokens")
                                Spacer()
                                TextField("Max Tokens", value: Binding(
                                    get: { settings.maxCompletionTokens ?? 100 },
                                    set: { settings.maxCompletionTokens = $0 }
                                ), format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                            }
                        }
                        
                        Toggle("Set Random Seed", isOn: .init(
                            get: { settings.seed != nil },
                            set: { if $0 { settings.seed = 42 } else { settings.seed = nil } }
                        ))
                        
                        if settings.seed != nil {
                            HStack {
                                Text("Seed")
                                Spacer()
                                TextField("Seed", value: Binding(
                                    get: { settings.seed ?? 42 },
                                    set: { settings.seed = $0 }
                                ), format: .number)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                            }
                        }
                    }
                    Text("Max tokens limits response length. Seed enables deterministic responses.")
                }
                
                Section {
                    ForEach(settings.stop.indices, id: \.self) { index in
                        TextField("Stop sequence", text: $settings.stop[index])
                    }
                    Button("Add Stop Sequence") {
                        settings.stop.append("")
                    }
                    if !settings.stop.isEmpty {
                        Button("Remove Last", role: .destructive) {
                            settings.stop.removeLast()
                        }
                    }
                }
                
                Section {
                    Picker("Service Tier", selection: Binding(
                        get: { settings.serviceTier ?? "auto" },
                        set: { settings.serviceTier = $0 }
                    )) {
                        Text("Auto").tag("auto")
                        Text("Flex").tag("flex")
                    }
                    Text("The service tier to use. Auto will automatically select the highest tier available within rate limits.")
                }
                
                Section {
                    Toggle("JSON Response", isOn: Binding(
                        get: { settings.responseFormat != nil },
                        set: { if $0 { 
                            settings.responseFormat = .init(type: "json_object") 
                        } else { 
                            settings.responseFormat = nil 
                        }}
                    ))
                    Text("Enable JSON mode to guarantee the message is valid JSON. Remember to instruct the model to produce JSON in your prompt.")
                }
            }
            .navigationTitle("Chat Settings")
        }
    }
}
