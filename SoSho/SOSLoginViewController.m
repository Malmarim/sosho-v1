//
//  SOSLoginViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 16.5.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSLoginViewController.h"
#import "SOSAppdelegate.h"
#import "SoShoStyleKit.h"

@interface SOSLoginViewController ()

@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation SOSLoginViewController


- (IBAction)buttonTouched:(id)sender
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.loginButton.transform = CGAffineTransformMakeScale(0.90, 0.90);
                     }];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.loginButton.transform = CGAffineTransformMakeScale(1, 1);
                     }];
    
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_location", @"user_birthday"]
        //[FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             // Retrieve the app delegate
             SOSAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
             
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
}

- (void) login
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"Login"          // Event label
                                                           value:nil] build]];    // Event value
    
    if(self.vote){
        [self performSegueWithIdentifier:@"logintovote" sender:self];
    }
    else{
        [self performSegueWithIdentifier:@"logintotour" sender:self];
        //[self performSegueWithIdentifier:@"logintoitem" sender:self];
    }
}

- (void) logout
{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        // If the session state is not any of the two "open" states when the button is clicked
    }
}

- (void) goVote
{
    [self performSegueWithIdentifier:@"logintovote" sender:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Login";
    [self.loginButton setImage:[SoShoStyleKit imageOfBTNLoginWithFacebook] forState:UIControlStateNormal];
    [self.loginButton setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"Mememory warning!");
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    if([[segue identifier] isEqualToString:@"logintovote"]){
        SOSVoteViewController *vote = (SOSVoteViewController *) [segue destinationViewController];
        vote.fbId = self.fbId;
        vote.pid = self.pid;
    }
    // Pass the selected object to the new view controller.
}

@end
