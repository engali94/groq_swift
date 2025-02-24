import SwiftUI
import GroqSwift

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @AppStorage("selectedTheme") private var selectedTheme = Theme.modern
    @AppStorage("selectedModel") private var selectedModel = GroqModel.mixtral_8x7b_32768
    @State private var showThemePicker = false
    @State private var showSettings = false
    @AppStorage("chatSettings") private var chatSettings: ChatSettings = ChatSettings()

    var body: some View {
        NavigationStack {
            ZStack {
                selectedTheme.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Text("Groq Chat")
                            .font(.title.bold())

                        Spacer()

                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "slider.horizontal.3")
                        }

                        Menu {
                            ThemePickerView(selectedTheme: $selectedTheme)
                            ModelPickerView(selectedModel: $selectedModel)
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .foregroundStyle(selectedTheme.accentColor)
                                .font(.title2)
                        }
                    }
                    .padding()

                    chatListView
                    messageInputView
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showSettings) {
            ChatSettingsView(settings: $chatSettings)
        }
    }

    private var chatListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        MessageView(message: message, theme: selectedTheme)
                            .id(message.id)
                            .transition(.moveAndFade)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .onChange(of: viewModel.messages) { _, _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()
                .background(selectedTheme.dividerColor)

            HStack(spacing: 12) {
                TextField("Message", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(selectedTheme.inputBackgroundColor)
                    .cornerRadius(20)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(selectedTheme.inputBorderColor, lineWidth: 0.5)
                    }
                    .font(.body)
                    .lineLimit(1...5)

                Button(action: sendMessage) {
                    Image(systemName: viewModel.isLoading ? "stop.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(messageText.isEmpty ? selectedTheme.buttonDisabledColor : selectedTheme.buttonEnabledColor)
                        .contentTransition(.symbolEffect(.replace))
                }
                .disabled(messageText.isEmpty && !viewModel.isLoading)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(selectedTheme.bottomBarColor)
        }
    }

    private func sendMessage() {
        if viewModel.isLoading {
            viewModel.cancelStreaming()
        } else {
            Task {
                await viewModel.sendMessage(messageText, model: selectedModel, settings: chatSettings)
                messageText = ""
            }
        }
    }
}

extension ChatCompletionRequest {
    func with(model: String, messages: [Message]) -> ChatCompletionRequest {
        ChatCompletionRequest(
            model: model,
            messages: messages,
            stream: self.stream,
            maxCompletionTokens: self.maxCompletionTokens,
            temperature: self.temperature,
            topP: self.topP,
            n: self.n,
            stop: self.stop,
            presencePenalty: self.presencePenalty,
            frequencyPenalty: self.frequencyPenalty,
            seed: self.seed,
            responseFormat: self.responseFormat,
            serviceTier: self.serviceTier,
            user: self.user
        )
    }
}
