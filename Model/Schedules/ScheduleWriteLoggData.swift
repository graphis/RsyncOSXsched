//
//  ScheduleWriteLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 19.04.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ScheduleWriteLoggData: SetConfigurations {

    var storageapi: PersistentStorageAPI?
    var schedules: [ConfigurationSchedule]?

    /// Function adds results of task to file (via memory). Memory are
    /// saved after changed. Used in either single tasks or batch.
    /// - parameter hiddenID : hiddenID for task
    /// - parameter result : String representation of result
    /// - parameter date : String representation of date and time stamp
    func addlogtaskmanuel(_ hiddenID: Int, result: String) {
        if ViewControllerReference.shared.detailedlogging {
            // Set the current date
            let currendate = Date()
            let dateformatter = Tools().setDateformat()
            let date = dateformatter.string(from: currendate)
            let config = self.getconfig(hiddenID: hiddenID)
            var resultannotaded: String?
            if config.task == "snapshot" {
                let snapshotnum = String(config.snapshotnum!)
                resultannotaded = "(" +  snapshotnum + ") " + result
            } else {
                resultannotaded = result
            }
            var inserted: Bool = self.addloggtaskmanualexisting(hiddenID, result: resultannotaded ?? "", date: date)
            // Record does not exist, create new Schedule (not inserted)
            if inserted == false {
                inserted = self.addloggtaskmanulnew(hiddenID, result: resultannotaded ?? "", date: date)
            }
            if inserted {
                self.storageapi!.saveScheduleFromMemory()
            }
        }
    }

    private func addloggtaskmanualexisting(_ hiddenID: Int, result: String, date: String) -> Bool {
        var loggadded: Bool = false
        for i in 0 ..< self.schedules!.count where
            self.configurations!.getResourceConfiguration(hiddenID, resource: .task) == "backup" {
                if self.schedules![i].hiddenID == hiddenID  &&
                    self.schedules![i].schedule == "manuel" &&
                    self.schedules![i].dateStop == nil {
                    let dict = NSMutableDictionary()
                    dict.setObject(date, forKey: "dateExecuted" as NSCopying)
                    dict.setObject(result, forKey: "resultExecuted" as NSCopying)
                    self.schedules![i].logrecords.append(dict)
                    loggadded = true
                }
            }
        return loggadded
    }

    private func addloggtaskmanulnew(_ hiddenID: Int, result: String, date: String) -> Bool {
        var loggadded: Bool = false
        if (self.configurations!.getResourceConfiguration(hiddenID, resource: .task) == "backup" ||
            self.configurations!.getResourceConfiguration(hiddenID, resource: .task) == "snapshot") {
            let masterdict = NSMutableDictionary()
            masterdict.setObject(hiddenID, forKey: "hiddenID" as NSCopying)
            masterdict.setObject("01 Jan 1900 00:00", forKey: "dateStart" as NSCopying)
            masterdict.setObject("manuel", forKey: "schedule" as NSCopying)
            let dict = NSMutableDictionary()
            dict.setObject(date, forKey: "dateExecuted" as NSCopying)
            dict.setObject(result, forKey: "resultExecuted" as NSCopying)
            let executed = NSMutableArray()
            executed.add(dict)
            let newSchedule = ConfigurationSchedule(dictionary: masterdict, log: executed)
            self.schedules!.append(newSchedule)
            loggadded = true
        }
        return loggadded
    }

    /// Function adds results of task to file (via memory). Memory are
    /// saved after changed. Used in either single tasks or batch.
    /// - parameter hiddenID : hiddenID for task
    /// - parameter dateStart : String representation of date and time stamp start schedule
    /// - parameter result : String representation of result
    /// - parameter date : String representation of date and time stamp for task executed
    /// - parameter schedule : schedule of task
    func addresultschedule(_ hiddenID: Int, dateStart: String, result: String, date: String, schedule: String) {
        if ViewControllerReference.shared.detailedlogging {
            var logged: Bool = false
            for i in 0 ..< self.schedules!.count where
                self.schedules![i].hiddenID == hiddenID  &&
                self.schedules![i].schedule == schedule &&
                self.schedules![i].dateStart == dateStart {
                    if (self.configurations!.getResourceConfiguration(hiddenID, resource: .task) == "backup" ||
                        self.configurations!.getResourceConfiguration(hiddenID, resource: .task) == "snapshot" ) {
                        logged = true
                        let dict = NSMutableDictionary()
                        var resultannotaded: String?
                        let config = self.getconfig(hiddenID: hiddenID)
                        if config.task == "snapshot" {
                            let snapshotnum = String(config.snapshotnum!)
                            resultannotaded = "(" +  snapshotnum + ") " + result
                        } else {
                            resultannotaded = result
                        }
                        dict.setObject(date, forKey: "dateExecuted" as NSCopying)
                        dict.setObject(resultannotaded ?? "", forKey: "resultExecuted" as NSCopying)
                        self.schedules![i].logrecords.append(dict)
                        self.storageapi!.saveScheduleFromMemory()
                    }
            }
            // This might happen if a task is executed by schedule and there are no previous logged run
            if logged == false {
                self.addlogtaskmanuel(hiddenID, result: result)
            }
        }
    }

    private func getconfig(hiddenID: Int) -> Configuration {
        let index = self.configurations?.getIndex(hiddenID) ?? 0
        return self.configurations!.getConfigurations()[index]
    }

    init() {
        self.schedules = [ConfigurationSchedule]()
    }
}
