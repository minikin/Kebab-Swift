//
//  UserNotificationCapability.swift
//  PSOperations
//
//  Created by Dev Team on 10/4/15.
//  Copyright © 2015 Pluralsight. All rights reserved.
//

#if os(iOS)

import UIKit
    
public struct UserNotification: CapabilityType {
    
    public static let name = "UserNotificaton"
    
    public static func didRegisterUserSettings() {
        authorizer.completeAuthorization()
    }
    
    public enum Behavior {
        case Replace
        case Merge
    }
    
    private let settings: UIUserNotificationSettings
    private let behavior: Behavior
    
    public init(settings: UIUserNotificationSettings, behavior: Behavior = .Merge) {
        self.settings = settings
        self.behavior = behavior
    }
    
    public func requestStatus(completion: CapabilityStatus -> Void) {
        let registered = authorizer.areSettingsRegistered(settings)
        completion(registered ? .Authorized : .NotDetermined)
    }
    
    public func authorize(completion: CapabilityStatus -> Void) {
        let settings: UIUserNotificationSettings
        
        switch behavior {
            case .Replace:
                settings = self.settings
            case .Merge:
                let current = UIApplication.sharedApplication().currentUserNotificationSettings()
                settings = current?.settingsByMerging(self.settings) ?? self.settings
        }
        
        authorizer.authorize(settings, completion: completion)
    }
    
}
    
private let authorizer = UserNotificationAuthorizer()
    
private class UserNotificationAuthorizer {
    
    var completion: (CapabilityStatus -> Void)?
    var settings: UIUserNotificationSettings?
    
    func areSettingsRegistered(settings: UIUserNotificationSettings) -> Bool {
        let current = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        return current?.contains(settings) ?? false
    }
    
    func authorize(settings: UIUserNotificationSettings, completion: CapabilityStatus -> Void) {
        guard self.completion == nil else {
            fatalError("Cannot request push authorization while a request is already in progress")
        }
        guard self.settings == nil else {
            fatalError("Cannot request push authorization while a request is already in progress")
        }
        
        self.completion = completion
        self.settings = settings
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    private func completeAuthorization() {
        
        guard let completion = self.completion else { return }
        guard let settings = self.settings else { return }
        
        self.completion = nil
        self.settings = nil
        
        let registered = areSettingsRegistered(settings)
        completion(registered ? .Authorized : .Denied)
    }
    
}

#endif
