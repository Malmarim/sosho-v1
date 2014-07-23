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


- (IBAction)buttonTouched:(id)sender {
    
    if((UIButton *) sender == self.yesButton){
        [self postVote:TRUE];
    }
    else if ((UIButton *)sender == self.noButton){
        [self postVote:FALSE];
    }
}

/*
 Posts users vote on the item online
 */
-(void)postVote:(BOOL) vote
{
    int voteInt;
    if(vote){
        NSLog(@"Yes");
        voteInt = 1;
    }else{
        NSLog(@"No");
        voteInt = 0;
    }
    
    long pid = (long)[self.item valueForKey:@"id"];
    NSString *url = @"http://soshoapp.herokuapp.com/vote";
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSString *params = [[NSString alloc] initWithFormat:@"fbId=%@&id=%ld&vote=%d", @"asd", pid, voteInt];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            NSLog(@"No Error");
        }
        else{
            NSLog(@"Error");
        }
    }];
    
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
    UIImage* shoe = [UIImage imageNamed:@"wishlist-button.png"];
    [self.backButton setImage:shoe forState:UIControlStateNormal];
    UIImage* yes = [UIImage imageNamed:@"yes-icon.png"];
    [self.yesButton setImage:yes forState:UIControlStateNormal];
    UIImage* no = [UIImage imageNamed:@"no-icon.png"];
    [self.noButton setImage:no forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
    // Check if item has already been set (coming from votes view)
    if([self.item count] > 0){
        NSURL *url = [NSURL URLWithString:[self.item valueForKey: @"image"]];
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                //[self.name setText:[item valueForKey: @"name"]];
                [self.shoeImage setImage:[[UIImage alloc] initWithData:data]];
            }
        }];
    }
    // If item is not set it needs to be from db or server
    else
    {
        [self.noButton setEnabled:false];
        [self.yesButton setEnabled:false];
        // Check if item with given id exists from local storage
        // If not check online and download from soshoapp.herokuapp.com/getById/id
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *data))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            completionBlock(YES, data);
        } else {
            completionBlock(NO, nil);
        }
    }];
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
