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
@property (weak, nonatomic) IBOutlet UIImageView *imageLogo;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *slogan;

@property (strong, nonatomic) UIFont *regular;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *background;

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
    if(self.vote){
        [self performSegueWithIdentifier:@"logintovote" sender:self];
    }
    else{
        [self performSegueWithIdentifier:@"logintoitem" sender:self];
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


-(UIImage *) drawWithText:(NSString *)text inImage:(UIImage *) image at:(CGPoint) point
{
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    NSDictionary *attrs = @{ NSFontAttributeName: [UIFont fontWithName:@"Lato-Regular" size:29], NSForegroundColorAttributeName: self.textColor};
    [text drawInRect:CGRectIntegral(rect) withAttributes:attrs];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Login";
    // Do any additional setup after loading the view.
    UIImage* bg = [UIImage imageNamed:@"bag-logo.png"];
    [self.imageLogo setImage:bg];
    UIImage* lg = [UIImage imageNamed:@"text-logo.png"];
    [self.logo setImage:lg];
    self.regular = [UIFont fontWithName:@"Lato-LightItalic" size:15];
    self.textColor = [UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1];
    [self.slogan setFont:self.regular];
    [self.slogan setTextColor:self.textColor];
    self.slogan.textAlignment = NSTextAlignmentCenter;
    UILabel *loginText = [UILabel alloc];
    loginText.text = @"LOG IN WITH FACEBOOK";
    UIImage* myImage = [UIImage imageNamed:@"facebook-login-button.png"];
    //UIImage* withText = [self drawWithText:@"LOG IN WITH FACEBOOK" inImage:myImage at:CGPointMake(125, 28)];
    [self.loginButton setImage:myImage forState:UIControlStateNormal];
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
