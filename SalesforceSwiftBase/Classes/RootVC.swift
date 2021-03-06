/*
Copyright (c) 2011, salesforce.com, inc. All rights reserved.

Redistribution and use of this software in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions
and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or other materials provided
with the distribution.
* Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
endorse or promote products derived from this software without specific prior written
permission of salesforce.com, inc.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 Author: @quintonwall
*/


import UIKit

class RootVC: UIViewController {
    

    let approvalsHandler: ApprovalsHandler = ApprovalsHandler()
    
    
    //  #pragma mark - view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = " Mobile SDK & Apple Watch Sample App"
        
        
        //let userDefaults = NSUserDefaults(suiteName: "group.com.salesforce.SalesforceWatch")
       // let data = "jack".dataUsingEncoding(NSUTF8StringEncoding)
       // userDefaults?.setValue(data, forKeyPath: "user.name")
       // userDefaults?.synchronize()
       // println("syncing app group")
        
        //add observer to listen for requests from WatchKit
        //TODO: move these to separate handlers.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleWatchKitNotification:"),
            name: "WatchKitSaysHello",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleWatchKitNotification:"),
            name: "approval-count",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleWatchKitNotification:"),
            name: "approval-details",
            object: nil)
        
        
        
        
       
        
        //[SFUserAccountManager sharedInstance].currentUser.fullName);
       
        
        //tmp test
        
        approvalsHandler.getApprovals()
        //approvalsHandler.updateApproval("04gj00000000pUpAAI", status: "Approved")
        
              
    }
    
    
    
    /*
     * When we receive a notification from watch, send request for data to Salesforce Platform
     * and return information back to watch.
     */
    func handleWatchKitNotification(notification: NSNotification) {
        
        //do this before any handler methods.
        if let watchInfo = notification.object as? WatchInfo {
            self.approvalsHandler.watchInfo = watchInfo
        }
        
        
        if(notification.name == "approval-count") {
            self.approvalsHandler.getApprovals()
            
        } else if (notification.name == "approval-details") {
                      if let info = self.approvalsHandler.watchInfo?.userInfo as? Dictionary<String,String> {
                if let s = info["id"] {
                   
                    self.approvalsHandler.getTargetObjectDetails(s)
                }
            }
        } else if (notification.name == "approval-update") {
            if let info = self.approvalsHandler.watchInfo?.userInfo as? Dictionary<String,String> {
                if let s = info["id"] {
                    self.approvalsHandler.updateApproval(s, status: "Approved")
                }
                    
            }
        }
    
    //end
    }
    
   
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
