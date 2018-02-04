//
//  ScheduleOperationDispatch.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 21.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

class ScheduleOperationDispatch: SecondsBeforeStart {
   
    private var pendingRequestWorkItem: DispatchWorkItem?
    private var configurations: Configurations?

    private func dispatchtask(_ seconds: Int) {
        let scheduledtask = DispatchWorkItem { [weak self] in
            _ = ExecuteTaskDispatch(configurations: self?.configurations)
        }
        self.pendingRequestWorkItem = scheduledtask
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: scheduledtask)
    }

    init(schedules: Schedules?, configurations: Configurations?) {
        self.configurations = configurations
        if schedules != nil {
            let seconds = self.secondsbeforestart(schedules: schedules, configurations: configurations)
            guard seconds > 0 else { return }
            self.dispatchtask(Int(seconds))
            // Set reference to schedule for later cancel if any
            ViewControllerReference.shared.dispatchTaskWaiting = self.pendingRequestWorkItem
        }
    }

}
