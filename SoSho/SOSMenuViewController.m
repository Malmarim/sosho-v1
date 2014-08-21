//
//  SOSMenuViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 27.7.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSMenuViewController.h"
#import "SOSLoginViewController.h"

@interface SOSMenuViewController ()

@property NSString *category;

@property (weak, nonatomic) IBOutlet UIImageView *menu;
@property (weak, nonatomic) IBOutlet UIButton *item;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *all;
@property (weak, nonatomic) IBOutlet UILabel *boots;
@property (weak, nonatomic) IBOutlet UILabel *designer;
@property (weak, nonatomic) IBOutlet UILabel *flats;
@property (weak, nonatomic) IBOutlet UILabel *heels;
@property (weak, nonatomic) IBOutlet UILabel *sandals;
@property (weak, nonatomic) IBOutlet UILabel *trainers;

@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (weak, nonatomic) IBOutlet UIButton *bootsButton;
@property (weak, nonatomic) IBOutlet UIButton *designerButton;
@property (weak, nonatomic) IBOutlet UIButton *flatsButton;
@property (weak, nonatomic) IBOutlet UIButton *heelsButton;
@property (weak, nonatomic) IBOutlet UIButton *sandalsButton;
@property (weak, nonatomic) IBOutlet UIButton *trainersButton;
@property (weak, nonatomic) IBOutlet UIButton *logout;

@property UIFont *font;
@property UIColor *textColor;

@property UIImage *selected;
@property UIImage *notSelected;

@property NSArray *buttons;
@property NSArray *names;
@property NSArray *labels;

@end

@implementation SOSMenuViewController

- (IBAction)buttonTouched:(id)sender {
    // Iterate through the buttons
    for (int i = 0; i <7; i++) {
        // If button matches selected index
        if((UIButton *)sender == [self.buttons objectAtIndex:i]){
            self.category = [self.names objectAtIndex:i];
            [[self.buttons objectAtIndex:i] setImage:self.selected forState:UIControlStateNormal];
        }
        // If button does not match
        else{
            [[self.buttons objectAtIndex:i] setImage:self.notSelected forState:UIControlStateNormal];
        }
    }
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
    self.buttons = [[NSArray alloc] initWithObjects:self.allButton, self.bootsButton, self.designerButton, self.flatsButton, self.heelsButton, self.sandalsButton, self.trainersButton, nil];
    self.names = [[NSArray alloc] initWithObjects:@"All", @"Boots", @"Designer", @"Flats", @"Heels", @"Sandals", @"Trainers", nil];
    self.labels = [[NSArray alloc] initWithObjects:self.all, self.boots, self.designer, self.flats, self.heels, self.sandals, self.trainers, nil];
    self.font = [UIFont fontWithName:@"Lato-Regular" size:18];
    self.textColor = [UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1];
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
    
    for (int i = 0; i <7; i++) {
        // Iterate through the buttons
        if([[self.names objectAtIndex:i] isEqualToString:self.category]){
            [[self.buttons objectAtIndex:i] setImage:self.selected forState:UIControlStateNormal];
        }
        else{
            [[self.buttons objectAtIndex:i] setImage:self.notSelected forState:UIControlStateNormal];
        }
    }
    
    for(int i = 0; i <7; i++){
        [[self.labels objectAtIndex:i] setTextColor:self.textColor];
        [[self.labels objectAtIndex:i] setFont:self.font];
    }
    
    [self.categoryLabel setTextColor:self.textColor];
    [self.categoryLabel setFont:self.font];
    
    UIImage *itemImage = [UIImage imageNamed:@"small-logo.png"];
    [self.item setImage:itemImage forState:UIControlStateNormal];
    
    UIImage *menuImage = [UIImage imageNamed:@"menu-button"];
    [self.menu setImage:menuImage];
    
    //[self.logout setTitleColor:self.textColor forState:UIControlStateNormal];
    self.logout.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.logout.titleLabel setFont:self.font];
    [self.logout.titleLabel setTextColor:self.textColor];
    //[self.logout.titleLabel setTextAlignment:NSTextAlignmentLeft];
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
    
    if([segue.identifier isEqualToString:@"menutologin"]){
        NSLog(@"Logging out");
        SOSLoginViewController *dest = segue.destinationViewController;
        [dest logout];
    }
}


@end
