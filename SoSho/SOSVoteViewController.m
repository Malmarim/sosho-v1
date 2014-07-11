//
//  SOSVoteViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 11.7.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSVoteViewController.h"

@interface SOSVoteViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *shoeImage;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@end

@implementation SOSVoteViewController

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
    UIImage* shoe = [UIImage imageNamed:@"fav-button.png"];
    [self.backButton setImage:shoe forState:UIControlStateNormal];
    UIImage* yes = [UIImage imageNamed:@"yes-icon.png"];
    [self.yesButton setImage:yes forState:UIControlStateNormal];
    UIImage* no = [UIImage imageNamed:@"no-icon.png"];
    [self.noButton setImage:no forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
