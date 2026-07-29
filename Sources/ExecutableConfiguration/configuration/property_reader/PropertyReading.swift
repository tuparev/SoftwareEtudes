//
//  PropertyReading.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 29.07.26.
//

import Foundation

public enum UserDefaultUsagePolicy {
    case useAllDefaults
    case useSelectedDefaults
    case useAllDefaultsAndPushBack
    case useSelectedDefaultsAndPushBack
}

public enum EnvironmentUsagePolicy {
    case useAllDefaults
    case useSelectedDefaults
    case useAllDefaultsAndPushBack
    case useSelectedDefaultsAndPushBack
}


public protocol PropertyReading {
    var domain: ConfigurationDomain { get set }
    var providers: [PropertyProviding] { get set }
    var userDefaultsPolicy: UserDefaultUsagePolicy { get set }
}

/*

 Reader is domain-based.

 Tasks:
 - Define the domain
 - Define the list of providers
 - Set provider policies


 1. Ordered list of providers (array)
 2. Should we use only properties defined in the Domain's Property file or all properties (e.g. env, userDefaults etc.
 3. Should we sync back to UserDefaults

 Q: What happens if there is no Property file for this domain?


 */
