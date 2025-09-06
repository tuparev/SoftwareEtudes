let message = Message(
    payload: .key(key: "logStart"),
    priority: .normal,
    arguments: ["?token": "abc123", "user": "alice"],
    actions: nil,
    formattingInfo: nil
)
Task {
    try await root.handle(message)
}
