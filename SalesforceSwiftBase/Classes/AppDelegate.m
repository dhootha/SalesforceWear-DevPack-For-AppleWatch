/*
 Copyright (c) 2011-2014, salesforce.com, inc. All rights reserved.
 
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
 */

#import "AppDelegate.h"
#import "InitialViewController.h"
//#import "RootViewController.h"
#import <SalesforceSDKCore/SFUserAccountManager.h>
#import <SalesforceSDKCore/SFAuthenticationManager.h>
#import <SalesforceSDKCore/SFPushNotificationManager.h>
#import <SalesforceSDKCore/SFDefaultUserManagementViewController.h>
#import <SalesforceOAuth/SFOAuthInfo.h>
#import <SalesforceCommonUtils/SFLogger.h>
#import "SalesforceSwiftBase-Bridging-Header.h"
#import "SalesforceWatch-Swift.h"


// Fill these in when creating a new Connected Application on Force.com
static NSString * const RemoteAccessConsumerKey = @"3MVG9fMtCkV6eLhdjZ8TO0bd8hGzu5J5yQgUxxSuCecbgoXyi.K29XllYaR_X0S5uGpH_kLhPbR2bMOys1U2D";
static NSString * const OAuthRedirectURI        = @"mobilesdk://success";

@interface AppDelegate () <SFAuthenticationManagerDelegate, SFUserAccountManagerDelegate>

/**
 * Success block to call when authentication completes.
 */
@property (nonatomic, copy) SFOAuthFlowSuccessCallbackBlock initialLoginSuccessBlock;

/**
 * Failure block to calls if authentication fails.
 */
@property (nonatomic, copy) SFOAuthFlowFailureCallbackBlock initialLoginFailureBlock;

/**
 * Convenience method for setting up the main UIViewController and setting self.window's rootViewController
 * property accordingly.
 */
- (void)setupRootViewController;

/**
 * (Re-)sets the view state when the app first loads (or post-logout).
 */
- (void)initializeAppViewState;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize initialLoginSuccessBlock = _initialLoginSuccessBlock;
@synthesize initialLoginFailureBlock = _initialLoginFailureBlock;

- (id)init
{
    self = [super init];
    if (self) {
        [SFLogger setLogLevel:SFLogLevelDebug];
        //has to be at least v30 to support approvals via the restful api
        
        // These SFAccountManager settings are the minimum required to identify the Connected App.
        [SFUserAccountManager sharedInstance].oauthClientId = RemoteAccessConsumerKey;
        [SFUserAccountManager sharedInstance].oauthCompletionUrl = OAuthRedirectURI;
        [SFUserAccountManager sharedInstance].scopes = [NSSet setWithObjects:@"web", @"api", nil];
       // [[SFRestAPI sharedInstance] setApiVersion:@"32.0"];

        
        // Auth manager delegate, for receiving logout and login host change events.
        [[SFAuthenticationManager sharedManager] addDelegate:self];
        [[SFUserAccountManager sharedInstance] addDelegate:self];
        
        //TEST
        //force login each time
         //[[SFAuthenticationManager sharedManager] logout];
        
        // Blocks to execute once authentication has completed.  You could define these at the different boundaries where
        // authentication is initiated, if you have specific logic for each case.
        __weak AppDelegate *weakSelf = self;
        self.initialLoginSuccessBlock = ^(SFOAuthInfo *info) {
            [weakSelf setupRootViewController];
        };
        self.initialLoginFailureBlock = ^(SFOAuthInfo *info, NSError *error) {
            [[SFAuthenticationManager sharedManager] logout];
        };
    }
   
    
    return self;
}

- (void)dealloc
{
    [[SFAuthenticationManager sharedManager] removeDelegate:self];
    [[SFUserAccountManager sharedInstance] removeDelegate:self];
}

#pragma mark - App delegate lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self initializeAppViewState];
    
    //
    // If you wish to register for push notifications, uncomment the line below.  Note that,
    // if you want to receive push notifications from Salesforce, you will also need to
    // implement the application:didRegisterForRemoteNotificationsWithDeviceToken: method (below).
    //
    //[[SFPushNotificationManager sharedInstance] registerForRemoteNotifications];
    //
    
    [[SFAuthenticationManager sharedManager] loginWithCompletion:self.initialLoginSuccessBlock failure:self.initialLoginFailureBlock];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //
    // Uncomment the code below to register your device token with the push notification manager
    //
    //[[SFPushNotificationManager sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    //if ([SFAccountManager sharedInstance].credentials.accessToken != nil) {
    //    [[SFPushNotificationManager sharedInstance] registerForSalesforceNotifications];
    //}
    //
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // Respond to any push notification registration errors here.
}



#pragma mark - Private methods

- (void)initializeAppViewState
{
   
    
    NSString * storyboardName = @"Main";
    NSString * viewControllerID = @"HomeView";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    self.window.rootViewController = (RootVC *)[storyboard instantiateViewControllerWithIdentifier:viewControllerID];
    [self.window makeKeyAndVisible];
}

- (void)setupRootViewController
{
    
    NSLog(@"HELLO: %@",[SFUserAccountManager sharedInstance].currentUser.fullName);
   
    //ApprovalsHandler *handler = [[ApprovalsHandler alloc] init];
    //[handler getApprovals];
    
    NSString * storyboardName = @"Main";
    NSString * viewControllerID = @"HomeView";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    RootVC * controller = (RootVC *)[storyboard instantiateViewControllerWithIdentifier:viewControllerID];
    self.window.rootViewController = controller;
}

#pragma mark - SFAuthenticationManagerDelegate

- (void)authManagerDidLogout:(SFAuthenticationManager *)manager
{
    [self log:SFLogLevelDebug msg:@"SFAuthenticationManager logged out.  Resetting app."];
    [self initializeAppViewState];
    
    // Multi-user pattern:
    // - If there are two or more existing accounts after logout, let the user choose the account
    //   to switch to.
    // - If there is one existing account, automatically switch to that account.
    // - If there are no further authenticated accounts, present the login screen.
    //
    // Alternatively, you could just go straight to re-initializing your app state, if you know
    // your app does not support multiple accounts.  The logic below will work either way.
    NSArray *allAccounts = [SFUserAccountManager sharedInstance].allUserAccounts;
    if ([allAccounts count] > 1) {
        SFDefaultUserManagementViewController *userSwitchVc = [[SFDefaultUserManagementViewController alloc] initWithCompletionBlock:^(SFUserManagementAction action) {
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
        }];
        [self.window.rootViewController presentViewController:userSwitchVc animated:YES completion:NULL];
    } else if ([[SFUserAccountManager sharedInstance].allUserAccounts count] == 1) {
        [SFUserAccountManager sharedInstance].currentUser = [[SFUserAccountManager sharedInstance].allUserAccounts objectAtIndex:0];
        [[SFAuthenticationManager sharedManager] loginWithCompletion:self.initialLoginSuccessBlock
                                                             failure:self.initialLoginFailureBlock];
    } else {
        [[SFAuthenticationManager sharedManager] loginWithCompletion:self.initialLoginSuccessBlock
                                                             failure:self.initialLoginFailureBlock];
    }
}

#pragma mark - SFUserAccountManagerDelegate

- (void)userAccountManager:(SFUserAccountManager *)userAccountManager
         didSwitchFromUser:(SFUserAccount *)fromUser
                    toUser:(SFUserAccount *)toUser
{
    [self log:SFLogLevelDebug format:@"SFUserAccountManager changed from user %@ to %@.  Resetting app.",
     fromUser.userName, toUser.userName];
    [self initializeAppViewState];
    [[SFAuthenticationManager sharedManager] loginWithCompletion:self.initialLoginSuccessBlock failure:self.initialLoginFailureBlock];
}

#pragma mark - New for WatchKit

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply
{
    NSLog(@"WATCHKIT: %@", userInfo);
    
    NSString *reqType = [userInfo objectForKey:@"request-type"];
    
    WatchInfo *winfo = [[WatchInfo alloc] initWithUserInfo:userInfo reply:reply];
    [[NSNotificationCenter defaultCenter] postNotificationName: reqType object:winfo];
    
 
}



@end
