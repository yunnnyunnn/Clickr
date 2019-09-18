//
//  Clickr.swift
//  Poweather
//
//  Created by Ting-Yang Chen on 11/1/16.
//  Copyright © 2016 Ting Yang Chen. All rights reserved.
//

import Foundation

public let defaultResetAtCount: UInt = 5

public struct ClickrUserDefaultsKeys {
    static func counted(forEventWithIdentifier identifier: String) -> String {
        return "tyc.clickr.\(identifier).counted"
    }
    static func resetAtCount(forEventWithIdentifier identifier: String) -> String {
        return "tyc.clickr.\(identifier).resetAtCount"
    }
}

public typealias ClickrResetTask = () -> Void

public class Clickr {
    
    // MARK: - Properties
    public static let shared = Clickr()
    
    private var resetTasks = [String: ClickrResetTask]()
    
    // MARK: - Init
    private init() { }
    
    // MARK: - Getters and Setters for counting
    public func setResetAtCount(_ count: UInt, forEventWithIdentifier identifier: String) {
        
        // If the count is not changed, do nothing.
        if count == self.resetAtCount(forEventWithIdentifier: identifier) {
            return
        }
        
        // Save reset count to device for this event.
        let userDefaultKey = ClickrUserDefaultsKeys.resetAtCount(forEventWithIdentifier: identifier)
        UserDefaults.standard.set(count, forKey: userDefaultKey)
        
        // Reset current count whenever reset count is reset.
        self.setCounted(0, forEventWithIdentifier: identifier)
    }
    
    public func resetAtCount(forEventWithIdentifier identifier: String) -> UInt {
        
        // Get reset count from device for this event .
        let userDefaultKey = ClickrUserDefaultsKeys.resetAtCount(forEventWithIdentifier: identifier)
        return UInt(UserDefaults.standard.integer(forKey: userDefaultKey))
    }
    
    public func setCounted(_ count: UInt, forEventWithIdentifier identifier: String) {
        
        // Save count to device for this event.
        let userDefaultKey = ClickrUserDefaultsKeys.counted(forEventWithIdentifier: identifier)
        UserDefaults.standard.set(count, forKey: userDefaultKey)
        
        // Check if we reach reset count.
        self.checkCount(forEventWithIdentifier: identifier)
    }
    
    public func counted(forEventWithIdentifier identifier: String) -> UInt {
        // Get current count for this event from device.
        let userDefaultKey = ClickrUserDefaultsKeys.counted(forEventWithIdentifier: identifier)
        return UInt(UserDefaults.standard.integer(forKey: userDefaultKey))
    }
    
    // MARK: - Actions
    private func checkCount(forEventWithIdentifier identifier: String) {
        if self.counted(forEventWithIdentifier: identifier) >= self.resetAtCount(forEventWithIdentifier: identifier),
            self.resetAtCount(forEventWithIdentifier: identifier) != 0,
            self.counted(forEventWithIdentifier: identifier) != 0 {
            self.reset(forEventWithIdentifier: identifier, shouldPerformResetTask: true)
        }
    }
    
    public func count(forEventWithIdentifier identifier: String, withRestTask task: ClickrResetTask?) {
        
        // Check if we have started counting for this event.
        let userDefaultKey = ClickrUserDefaultsKeys.resetAtCount(forEventWithIdentifier: identifier)
        if UserDefaults.standard.object(forKey: userDefaultKey) == nil {
            // Event has not been counted yet. Set default reset count.
            self.setResetAtCount(defaultResetAtCount, forEventWithIdentifier: identifier)
        }
        
        // Set task and count
        self.resetTasks[identifier] = task
        let beforeCount = self.counted(forEventWithIdentifier: identifier)
        self.setCounted(beforeCount + 1, forEventWithIdentifier: identifier)
    }
    
    public func reset(forEventWithIdentifier identifier: String, shouldPerformResetTask: Bool) {
        
        // Reset count for this event.
        self.setCounted(0, forEventWithIdentifier: identifier)
        
        // Perform reset task if needed.
        if shouldPerformResetTask {
            if let taskToRun = self.resetTasks[identifier] {
                taskToRun()
            } else {
                print("No task to run at reset. Make sure to set a task for your event with identifier \(identifier).")
            }
        }
    }
}
