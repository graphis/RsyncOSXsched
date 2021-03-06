//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

// The Operation object to execute a scheduled job.
// The object get the hiddenID for the job, reads the
// rsync parameters for the job, creates a object to finalize the
// job after execution as logging. The reference to the finalize object
// is set in the static object. The finalize object is invoked
// when the job discover (observs) the termination of the process.

class ExecuteTaskDispatch: SetScheduledTask, SetConfigurations, Setlog {

    let outputprocess = OutputProcess()
    var arguments: [String]?
    var config: Configuration?
    weak var updatestatuslightDelegate: Updatestatuslight?

    private func executeTaskDispatch() {
        self.updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        // Get the first job of the queue
        if let dict: NSDictionary = ViewControllerReference.shared.scheduledTask {
            if let hiddenID: Int = dict.value(forKey: "hiddenID") as? Int {
                self.logDelegate?.addlog(logrecord: "Executing task hiddenID: " + String(hiddenID))
                let getconfigurations: [Configuration]? = configurations?.getConfigurations()
                guard getconfigurations != nil else { return }
                let configArray = getconfigurations!.filter({return ($0.hiddenID == hiddenID)})
                guard configArray.count > 0 else { return }
                config = configArray[0]
                // Inform and notify
                self.scheduleJob?.start()
                if hiddenID >= 0 && config != nil {
                    arguments = RsyncParametersProcess().argumentsRsync(config!, dryRun: false, forDisplay: false)
                    // Setting reference to finalize the job, finalize job is done when rsynctask ends (in process termination)
                    ViewControllerReference.shared.completeoperation = CompleteScheduledOperation(dict: dict)
                    if self.arguments != nil {
                        weak var sendprocess: Sendprocessreference?
                        sendprocess = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
                        let process = RsyncScheduled(arguments: self.arguments)
                        globalMainQueue.async(execute: {
                            process.executeProcess(outputprocess: self.outputprocess)
                            sendprocess?.sendprocessreference(process: process.getProcess())
                            sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
                        })
                    }
                }
            } else {
                self.updatestatuslightDelegate?.updatestatuslight(color: .red)
                self.logDelegate?.addlog(logrecord: "No hiddenID in dictionary")
            }
        } else {
            self.updatestatuslightDelegate?.updatestatuslight(color: .red)
            self.logDelegate?.addlog(logrecord: "No record for scheduled task: ViewControllerReference.shared.scheduledTask")
        }
    }

    init () {
        self.executeTaskDispatch()
    }
}
