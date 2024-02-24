# SoftwareEtudes

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftuparev%2FSoftwareEtudes%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/tuparev/SoftwareEtudes)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftuparev%2FSoftwareEtudes%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/tuparev/SoftwareEtudes)

## Intro
This repository is not focused on a single project. It is a collection of ideas, sources, and hopefully useful sources for fellow developers using Apple infrastructure, including server side Swift.

## Modules

### Utilities
Most of the sources in the `Utility` module are ready to be used. Please note, that some of the types are poorly documented and / or tested! See `To Do` section below if you like to contribute.

#### Date+GeneralExtensions
#### Debugging
#### FilesAndPaths
#### SemanticVersion
#### String+Additions
#### String+EmailAddressChecker
#### TimeIntervalUtilities
#### TypeNameDescribable
#### URL+BugFixes
#### URL+CodableExtensions

### ConfigurationEnvironment
The sources in this module are very preliminary and so far only as a starting point for brainstorming. The should NOT be used in real projects and there will be NO backwards compatibility!

### Messages

### Logging

### Graphs

## Tutorials

## ChangeLog
- 23.02.2024 - Releasing version 0.1.0. With this version we moved previous sources to the Utilities module and created To Do list for contributors.
- 18.02.2024 - restarted the repository. The existing repository with the same name got very messy. It had several abandoned branches containing some useful sources, but difficult to merge. So, I decided to delete the existing repository and start fresh.

## To Do
Dear users of this Swift Package, contributions are very welcome and you will be mention as a contributor (or anonymous contributor if you prefer) if you submit pull requests, that are accepted. If you are new to the package and would like to contribute, please pick one of the items in the ToDo list below.

### Starter items
- `TimeIntervalUtilities` needs documentation.
- `Debugging` needs documentation and testing.
- `String+Additions` needs documentation and tests should be revisited and enhanced. Also some of the methods (made reusable from elsewhere) are wrong!
- `TimeIntervalUtilities` needs documentation and more tests
- `TypeNameDescribable` needs (usage) documentation.
- `URL+BugFixes` needs tests.
- `URL+CodableExtensions` needs documentation and tests

### Functionality enhancements

### New APIs
