//
//  userconfiguration.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

// Reading userconfiguration from file into RsyncOSX
final class Userconfiguration {

    private func readUserconfiguration(dict: NSDictionary) {
        // Another version of rsync
        if let version3rsync = dict.value(forKey: "version3Rsync") as? Int {
            if version3rsync == 1 {
                ViewControllerReference.shared.rsyncVer3 = true
            } else {
                ViewControllerReference.shared.rsyncVer3 = false
            }
        }
        // Detailed logging
        if let detailedlogging = dict.value(forKey: "detailedlogging") as? Int {
            if detailedlogging == 1 {
                ViewControllerReference.shared.detailedlogging = true
            } else {
                ViewControllerReference.shared.detailedlogging = false
            }
        }
        if let executeinmenuapp = dict.value(forKey: "executeinmenuapp") as? Int {
            if executeinmenuapp == 1 {
                ViewControllerReference.shared.executescheduledtasksmenuapp = true
            } else {
                ViewControllerReference.shared.executescheduledtasksmenuapp = false
            }
        }
        // Optional path for rsync
        if let rsyncPath = dict.value(forKey: "rsyncPath") as? String {
            ViewControllerReference.shared.rsyncPath = rsyncPath
        }
        // Paths rsyncOSX and RsyncOSXsched
        if let pathrsyncosx = dict.value(forKey: "pathrsyncosx") as? String {
            ViewControllerReference.shared.pathrsyncosx = pathrsyncosx
        }
        if let pathrsyncosxsched = dict.value(forKey: "pathrsyncosxsched") as? String {
            ViewControllerReference.shared.pathrsyncosxsched = pathrsyncosxsched
        }
    }

    init (userconfigRsyncOSX: [NSDictionary]) {
        if userconfigRsyncOSX.count > 0 {
            self.readUserconfiguration(dict: userconfigRsyncOSX[0])
        }
    }
}
