//
//  SOSTourViewController.m
//  
//
//  Created by Mikko Malmari on 1.11.2014.
//
//

#import "SOSTourViewController.h"

@interface SOSTourViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tourImage;
@property (strong, nonatomic) NSArray *images;
@property (nonatomic) int index;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation SOSTourViewController

- (IBAction)setPrevious:(id)sender {
    if(self.index > 0){
        self.index--;
        [self setCurrentImage:NO];
    }
}

- (IBAction)setNext:(id)sender {
    if(self.index < [self.images count]-1){
        self.index++;
        [self setCurrentImage:YES];
    }else{
        [self hideTutorial];
    }
}

- (void)hideTutorial{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"seenTutorial"];
    [defaults synchronize];
    [self performSegueWithIdentifier:@"tourtoitem" sender:self];
}

- (IBAction)skipPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Skip tutorial?" message:@"Do you want to skip the tutorial, it will not be shown again." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Skip", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [self hideTutorial];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.images = [NSArray arrayWithObjects:[UIImage imageNamed:@"tour1.png"], [UIImage imageNamed:@"tour2.png"], [UIImage imageNamed:@"tour3.jpg"], [UIImage imageNamed:@"tour4.jpg"], [UIImage imageNamed:@"tour5.jpg"], nil];
    self.index = 0;
    //[self.tourImage setImage:[self.images objectAtIndex:self.index]];
    
    // Do any additional setup after loading the view.
}

- (void)setCurrentImage:(BOOL)next{
    [self.tourImage setImage:[self.images objectAtIndex:(NSUInteger)self.index]];
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    if(next)
        [animation setSubtype:kCATransitionFromRight];
    else
        [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[self.tourImage layer] addAnimation:animation forKey:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
