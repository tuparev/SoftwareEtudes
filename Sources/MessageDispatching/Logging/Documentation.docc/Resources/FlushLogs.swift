import SoftwareEtudesLogging

// Manually flush buffered logs to disk
await fileDispatcher.flush()

// Useful before app termination
func applicationWillTerminate() async {
    await fileDispatcher.flush()
}

