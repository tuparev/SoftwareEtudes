# SoftwareEtudes Logging


A flexible client-server and server-server oriented Logging API written in Swift. Current version requires Swift 5.3 or higher (as part of the SoftwareEtudes framework), but if used as separate files it might work with Swift 5.0 (untested).

First things first: the idea for creating these API was born out of frustration watching the SwiftLog discussion, which one could diplomatically express as naive. During the last 25 years I was involved in several large projects who needed flexible and powerful logging module. This API is reflects my experiences mostly from several large WebObjects based projects in the fields of finance and banking, robotic astronomy, publishing, and research software. Early version of SoftwareEtudes Logging is used currently by a large research project in astronomy, in a system for high-load financial transactions and in the experimental BrainObjects project.

## Goals

#### LogEntry should carry a very small payload that will be interpreted by the receiver.
Most logging modules are bases on String message and bunch of (mostly predefined) additional arguments like timestamp, file, and line number information etc. The message format is freestyle and could not be algorithmically processed. In contrast, `SoftwareEtudes`' LogEntry's payload is just an enum - either and `Int` code, or a `String` key. Together with privacy hint and optional arguments (a `Dictionary`) this payload gives the receiver of the LogEntry complete freedom for interpretation, storage, localisation, and display of the `LogEntry` (see additional goals).

#### Log Messages should be localisable
OK, English is not the only language, specially if you are not a developer. That's it!

#### Logging should facilitate performance measuring and turning
`LogEntries` should be (optionally) configurable as (hierarchically organised, or nested) signposts. In addition, this should not distort performance measurements.

#### Creating a `LogEntry` should not block the app execution
So, the Logging module should be fast and non-blocking.

#### Privacy
Private information should stay private. While debugging a `LogEntry` could contain private information. But not in production.

#### Persistency
The receiving system may decide archive logging information. Therefore, a `LogEntry` should contain a hint of how long it should be archived. 

## Types

## Architecture

## Getting started

`Logging` is part of the `SoftwareEtudes` framework. To depend on the `Logging` module, you need to declare your dependancy in your `Package.swift`:

```swift
.package(url: "https://github.com/tuparev/SoftwareEtudes.git",.branch("dev")),
```

Because `SoftwareEtudes` is in active development it is recommended to use the `dev` branch. I am trying to commit only tested sources there.