//
//  SOSLoginViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 16.5.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSLoginViewController.h"
#import "SOSAppdelegate.h"

@interface SOSLoginViewController ()

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UIImageView *slogan;

@end

@implementation SOSLoginViewController


- (IBAction)buttonTouched:(id)sender
{
    
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
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
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
    [self performSegueWithIdentifier:@"LoggedIn" sender:self];
}

- (void) logout
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    // Do any additional setup after loading the view.
    UIImage* bg = [UIImage imageNamed:@"pic-logo.png"];
    [self.background setImage:bg];
    UIImage* lg = [UIImage imageNamed:@"text-logo.jpg"];
    [self.logo setImage:lg];
    UIImage* sl = [UIImage imageNamed:@"slogan.jpg"];
    [self.slogan setImage:sl];
    UIImage* myImage = [UIImage imageNamed:@"login-button.png"];
    [self.loginButton setImage:myImage forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
