let url = Bundle.main.url(forResource: "dispatchers", withExtension: "json")!
let context = try MessageDispatchingContext.dispatchingContextWith(url: url)
guard let root = context.rootDispatcher() else {
    fatalError("No root dispatcher found")
}
