//
//  LockManager.swift
//
//
//  Created by Georg Tuparev on 23/11/26.
//  Copyright © See Framework's LICENSE file
//
//  Thanks for contributions, suggestions, ideas by:
//      1. - Georgi Karageorgiev - see CONTRIBUTORS
//

import Foundation

//TODO: Add tests!
//TODO: (Later, perhaps) Make possible to change the extension of the lock file?

public actor LockManager {

    public enum LockError: Error {
        case cannotAccessMonitoringFolder
        case cannotCreateLockFile
        case cannotDeleteLockFile
        case lockFileExists
    }

    public init(lockName: String?, monitoringFolder: String, ) {
        self.monitoringFolder = monitoringFolder
        self.lockName         = lockName == nil ? "" : lockName!
        self.monitoringLockPath = "\(monitoringFolder)/\(self.lockName)\(defaultLockFileName)"
    }

    public func isLocked() throws -> Bool { checkMonitoringPathExists() && fm.isReadableFile(atPath: monitoringLockPath) }

    public func lock() throws {

        if !checkMonitoringPathExists() { throw LockError.cannotAccessMonitoringFolder }

        // `YYYYmmdd-HHMMSS`
        let lockFormatter = DateFormatter()
        lockFormatter.dateFormat = "yyyyMMdd-HHmmss"

        let lockTimeString = lockFormatter.string(from: Date.now)
        let fileContent = Data(lockTimeString.utf8)

        if fm.isReadableFile(atPath: monitoringLockPath)                     { throw LockError.lockFileExists }
        if !fm.createFile(atPath: monitoringLockPath, contents: fileContent) { throw LockError.cannotCreateLockFile }
    }

    public func unlock() throws {
        if !checkMonitoringPathExists() { throw LockError.cannotAccessMonitoringFolder }

        do    { try fm.removeItem(atPath: monitoringLockPath) }
        catch { throw LockError.cannotDeleteLockFile }
    }

    //MARK: - Privare APIs -
    private let defaultLockFileName = ".lock"

    private var monitoringFolder: String
    private var lockName: String
    private var monitoringLockPath: String

    private let fm              = FileManager.default
    private var isDir: ObjCBool = false

    private func checkMonitoringPathExists() -> Bool {
        if (fm.fileExists(atPath: monitoringFolder, isDirectory: &isDir) && (isDir.boolValue)) { return true }
        else                                                                                   { return false }
    }

}
