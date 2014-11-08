//
//  SOSAppDelegate.m
//  SoSho
//
//  Created by Mikko Malmari on 16.5.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSAppDelegate.h"
#import "GAI.h"

/******* Set your tracking ID here *******/

@implementation SOSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-55736714-1"];
    
    self.navi = (UINavigationController *) self.window.rootViewController;
    self.sosLoginViewController = (SOSLoginViewController *)self.navi.topViewController;
    // Let the device know we want to receive push notifications
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
	//[[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_location", @"user_birthday"]
        //[FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
    
    if (launchOptions != nil)
	{
		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			//NSLog(@"Launched from push notification: %@", dictionary);
            if([[dictionary valueForKey:@"type"] isEqualToString:@"vote"]){
                [self voteReceivedMessage:[dictionary valueForKey:@"name"]];
            }else if([[dictionary valueForKey:@"type"] isEqualToString:@"message"]){
                self.friend = [[SOSFacebookFriend alloc] init];
                self.friend.id = [dictionary valueForKey:@"id"];
                self.friend.name = [dictionary valueForKey:@"name"];
                [self messageReceivedMessage:[dictionary valueForKey:@"message"] from:[dictionary valueForKey:@"name"]];
            }
		}
	}
    
    // Playfair-Display-Bold
    /*
    for(NSString *family in [UIFont familyNames]){
        NSLog(@"Family: %@", family);
        for(NSString *name in [UIFont fontNamesForFamilyName:family]){
            NSLog(@"Name: %@", name);
        }
    }*/
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Push");
    // app was already in the foreground
    if ( application.applicationState == UIApplicationStateActive ){
        //NSLog(@"Message received %@ active", userInfo);
        if([[userInfo valueForKey:@"type"] isEqualToString:@"vote"]){
            [self voteReceivedMessage:[userInfo valueForKey:@"name"]];
        }else if([[userInfo valueForKey:@"type"] isEqualToString:@"message"]){
            // Handle push notification
            //NSLog(@"Message");
            self.friend = [[SOSFacebookFriend alloc] init];
            self.friend.id = [userInfo valueForKey:@"id"];
            self.friend.name = [userInfo valueForKey:@"name"];
            [self messageReceivedMessage:[userInfo valueForKey:@"message"] from:[userInfo valueForKey:@"name"]];
        }
    }
    // app was just brought from background to foreground
    else{
        //NSLog(@"Message received %@ background", userInfo);
        if([[userInfo valueForKey:@"type"] isEqualToString:@"vote"]){
            [self voteReceivedMessage:[userInfo valueForKey:@"name"]];
        }else if([[userInfo valueForKey:@"type"] isEqualToString:@"message"]){
            // Handle push notification
            //NSLog(@"Message");
            self.friend = [[SOSFacebookFriend alloc] init];
            self.friend.id = [userInfo valueForKey:@"id"];
            self.friend.name = [userInfo valueForKey:@"name"];
            [self messageReceivedMessage:[userInfo valueForKey:@"message"] from:[userInfo valueForKey:@"name"]];
        }
    }
}

- (void) messageReceivedMessage:(NSString *)message from:(NSString * )friend
{
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message received" message:[NSString stringWithFormat:@"%@: %@", friend, message] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show", nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:[NSString stringWithFormat:@"%@: %@", friend, message] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        
    }
}*/

- (void) voteReceivedMessage:(NSString *)name
{
    [self showMessage:[NSString stringWithFormat:@"Your friend just voted on %@", name] withTitle:@"Vote received!"];
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        [self userLoggedOut];
    }
    // Handle errors
    if (error){
        //NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    [self.sosLoginViewController logout];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    [self.sosLoginViewController login];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Formatted as %@", newToken);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *oldToken = [defaults objectForKey:@"pushtoken"];
    //NSLog(@"Old: %@", oldToken);
    // Check if pushtoken is not set or newToken is same as set token
    if(oldToken == nil || ![oldToken isEqualToString:newToken]){
        [defaults setValue:newToken forKey:@"pushtoken"];
        [defaults synchronize];
        NSString *fbId = [defaults objectForKey:@"fbId"];
        // If fbId is set then update the new token on the server
        if(fbId != nil){
            // Post updated push token
            NSString *url = @"http://soshoapp.herokuapp.com/newToken";
            NSURL * fetchURL = [NSURL URLWithString:url];
            NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
            NSString *params = [[NSString alloc] initWithFormat:@"fbId=%@&pushtoken=%@", fbId, newToken];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
            NSOperationQueue * queue = [[NSOperationQueue alloc]init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
                if(!error){
                    //NSLog(@"No Error");
                }
                else{
                    //NSLog(@"Error: ");
                }
            }];
        }
    }else{
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
   //NSLog(@"Failed to get token, error: %@", error);
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *scheme = [url scheme];
    NSString *query = [url query];
   //NSLog(@"Scheme: %@", scheme);
   //NSLog(@"Query: %@", query);
    if([scheme isEqualToString:@"soshoapp"]){
        NSDictionary *params = [self parseURLParams:query];
       //NSLog(@"%@", [params valueForKey:@"pid"]);
        self.sosLoginViewController.vote = true;
        self.sosLoginViewController.fbId = [params valueForKey:@"fbId"];
         NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
        self.sosLoginViewController.pid = [formatString numberFromString:[params valueForKey:@"pid"]];
        if(FBSession.activeSession.state == FBSessionStateOpen){
            //NSLog(@"Session found, going to vote");
            [self.sosLoginViewController goVote];
        }
        return true;
    }
    else{
        BOOL urlWasHandled =
        [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler: ^(FBAppCall *call) {
            // Parse the incoming URL to look for a target_url parameter
            NSString *query = [url query];
            NSDictionary *params = [self parseURLParams:query];
            // Check if target URL exists
            NSString *appLinkDataString = [params valueForKey:@"al_applink_data"];
            if (appLinkDataString) {
                NSError *error = nil;
                NSDictionary *applinkData =
                [NSJSONSerialization JSONObjectWithData:[appLinkDataString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                if (!error && [applinkData isKindOfClass:[NSDictionary class]] && applinkData[@"target_url"]) {
                    //NSString *targetURLString = applinkData[@"target_url"];
                    // Show the incoming link in an alert
                    // Your code to direct the user to the
                    // appropriate flow within your app goes here
                    //[[[UIAlertView alloc] initWithTitle:@"Received link:" message:targetURLString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }
        }];
        return urlWasHandled;
    }
}

// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
           //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SoSho" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SoSho.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
