//
//  NetworkMonitor.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 13.09.24.
//

import Foundation
import Network


open class NetworkMonitor {

    public struct NetworkStatusChangeNotifications {

    }

    public enum NetworkError: Error {
        case noConnection
        case invalidURL
        case requestFailed(Error)
        case invalidData
    }

    public static var shared = NetworkMonitor()

    public var isConnected = true


    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        networkMonitor.start(queue: workerQueue)
    }

    private let networkMonitor = NWPathMonitor()
    private let workerQueue    = DispatchQueue(label: "NetworkMonitorQueue")

}
