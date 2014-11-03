//
//  SOSOptionsViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 5.9.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSOptionsViewController.h"
#import "SOSLoginViewController.h"
#import "SoShoStyleKit.h"

@interface SOSOptionsViewController ()

@property NSString *category;

@property (weak, nonatomic) IBOutlet UIImageView *menu;
@property (weak, nonatomic) IBOutlet UIButton *item;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *all;
@property (weak, nonatomic) IBOutlet UILabel *ballerinas;
@property (weak, nonatomic) IBOutlet UILabel *boots;
@property (weak, nonatomic) IBOutlet UILabel *brogues;
@property (weak, nonatomic) IBOutlet UILabel *espadrilles;
@property (weak, nonatomic) IBOutlet UILabel *flipflops;
@property (weak, nonatomic) IBOutlet UILabel *laceupshoe;
@property (weak, nonatomic) IBOutlet UILabel *loafers;
@property (weak, nonatomic) IBOutlet UILabel *mules;
@property (weak, nonatomic) IBOutlet UILabel *pumps;
@property (weak, nonatomic) IBOutlet UILabel *sandals;
@property (weak, nonatomic) IBOutlet UILabel *slippers;
@property (weak, nonatomic) IBOutlet UILabel *trainers;

@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (weak, nonatomic) IBOutlet UIButton *ballerinasButton;
@property (weak, nonatomic) IBOutlet UIButton *bootsButton;
@property (weak, nonatomic) IBOutlet UIButton *broguesButton;
@property (weak, nonatomic) IBOutlet UIButton *espadrillesButton;
@property (weak, nonatomic) IBOutlet UIButton *flipflopsButton;
@property (weak, nonatomic) IBOutlet UIButton *laceupshoeButton;
@property (weak, nonatomic) IBOutlet UIButton *loafersButton;
@property (weak, nonatomic) IBOutlet UIButton *mulesButton;
@property (weak, nonatomic) IBOutlet UIButton *pumpsButton;
@property (weak, nonatomic) IBOutlet UIButton *sandalsButton;
@property (weak, nonatomic) IBOutlet UIButton *slippersButton;
@property (weak, nonatomic) IBOutlet UIButton *trainersButton;
 
@property (weak, nonatomic) IBOutlet UIButton *logout;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *icons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

@property (weak, nonatomic) IBOutlet UIView *tabBar;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UIButton *messagesButton;

//@property UIFont *font;
//@property UIColor *textColor;

@property UIImage *selected;
@property UIImage *notSelected;

//@property NSArray *buttons;
@property NSArray *names;
//@property NSArray *labels;

@end

@implementation SOSOptionsViewController

- (IBAction)buttonTouched:(id)sender {
    NSLog(@"Button pressed");
    // Iterate through the buttons
    int i = 0;
    for(UIButton *button in self.buttons){
        if(sender == button){
            NSLog(@"Button %d", i);
            self.category = [self.names objectAtIndex:i];
            [self sendEvent:[NSString stringWithFormat:@"Category: %@" , self.category]];
            [(UIImageView *)[self.icons objectAtIndex:i] setImage:self.selected];
        }else{
            [(UIImageView *)[self.icons objectAtIndex:i] setImage:self.notSelected];
        }
        i++;
    }
}

- (void)sendEvent:(NSString *) label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:label          // Event label
                                                           value:nil] build]];    // Event value
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
    
    self.screenName = @"Options";
    /*self.buttons = [[NSArray alloc] initWithObjects:self.allButton, self.ballerinasButton, self.bootsButton, self.broguesButton, self.espadrillesButton, self.flipflopsButton, self.laceupshoeButton, self.loafersButton, self.mulesButton, self.pumpsButton, self.sandalsButton, self.slippersButton, self.trainersButton, nil];*/
    self.names = [[NSArray alloc] initWithObjects:@"All", @"Ballerinas", @"Boots", @"Brogues", @"Espadrilles", @"Flip Flops", @"Lace-up Shoe", @"Loafers", @"Mules", @"Pumps", @"Sandals", @"Slippers", @"Trainers", nil];
    /*self.labels = [[NSArray alloc] initWithObjects:self.all, self.ballerinas, self.boots, self.brogues, self.espadrilles, self.flipflops, self.laceupshoe, self.loafers, self.mules, self.pumps, self.sandals, self.slippers, self.trainers, nil];
    */
    self.selected = [UIImage imageNamed:@"selected.png"];
    self.notSelected = [UIImage imageNamed:@"not-selected.png"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"category"] == nil){
        self.category = @"All";
        [defaults setObject:self.category forKey:@"category"];
        [defaults synchronize];
    }
    else
    {
        self.category = [defaults objectForKey:@"category"];
    }
    
    for (int i = 0; i <13; i++) {
        // Iterate through the buttons
        if([[self.names objectAtIndex:i] isEqualToString:self.category]){
            [(UIImageView *)[self.icons objectAtIndex:i] setImage:self.selected];
        }
        else{
            [(UIImageView *)[self.icons objectAtIndex:i] setImage:self.notSelected];
        }
    }
    
    UIFont *myFont = [UIFont fontWithName:@"Lato-Regular" size:12];
    UIColor *myColor = [UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1];
    
    
    for(int i = 0; i <13; i++){
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[self.names objectAtIndex:i] uppercaseString]];
        
        [attributedString addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attributedString.length)];
        
        ((UILabel *)[self.labels objectAtIndex:i]).attributedText = attributedString;
        [[self.labels objectAtIndex:i] setTextColor:myColor];
        [[self.labels objectAtIndex:i] setFont:myFont];
    }
    
    UIFont *headerFont = [UIFont fontWithName:@"Lato-Black" size:20];
    
    [self.categoryLabel setTextColor:myColor];
    [self.categoryLabel setFont:headerFont];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"CATEGORIES"];
    [attributedString addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attributedString.length)];
    self.categoryLabel.attributedText = attributedString;
    
    [self.item setImage:[SoShoStyleKit imageOfBtnMainMenu] forState:UIControlStateNormal];
    
    //[self.menu setImage:menuImage];
    
    //[self.logout setTitleColor:self.textColor forState:UIControlStateNormal];
    self.logout.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.logout.titleLabel setFont:myFont];
    [self.logout.titleLabel setTextColor:myColor];
    //[self.logout.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 620)];
    
    [self.homeButton setImage:[SoShoStyleKit imageOfTabBarHomeActive] forState:UIControlStateNormal];
    //[self.homeButton setContentMode:UIViewContentModeScaleAspectFit];
    [self.wishlistButton setImage:[SoShoStyleKit imageOfTabBarWishlistInActive] forState:UIControlStateNormal];
    //[self.wishlistButton setContentMode:UIViewContentModeScaleAspectFit];
    [self.messagesButton setImage:[SoShoStyleKit imageOfTabBarMessagesInActive] forState:UIControlStateNormal];
    //[self.messagesButton setContentMode:UIViewContentModeScaleAspectFit];
    //[self.moreButton setImage:[SoShoStyleKit imageOfTabBarMoreInActive] forState:UIControlStateNormal];
    //[self.moreButton setContentMode:UIViewContentModeScaleAspectFit];
    // Add a topBorder.
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, self.tabBar.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithRed: 1 green: 0.463 blue: 0.376 alpha: 1].CGColor;
    [self.tabBar.layer addSublayer:topBorder];
    
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.category forKey:@"category"];
    [defaults synchronize];
    
    if([segue.identifier isEqualToString:@"logout"]){
        [self sendEvent:@"Logout"];
        NSLog(@"Logging out");
        SOSLoginViewController *dest = segue.destinationViewController;
        //[FBSession.activeSession closeAndClearTokenInformation];
        [dest logout];
    }else{
        [self sendEvent:@"Item (from options)"];
    }
}


@end
