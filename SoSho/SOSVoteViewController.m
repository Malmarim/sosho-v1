//
//  SOSVoteViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 11.7.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSVoteViewController.h"
#import "SOSAppDelegate.h"

@interface SOSVoteViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *shoeImage;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property NSDictionary *voteObject;

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
    
    NSString *url = @"http://soshoapp.herokuapp.com/vote";
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSString *params = [[NSString alloc] initWithFormat:@"fbId=%@&id=%ld&vote=%d", self.fbId, [self.pid longValue], voteInt];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            //NSLog(@"No Error");
            // set voted true
            [self.noButton setEnabled:false];
            [self.yesButton setEnabled:false];
        }
        else{
            //NSLog(@"Error");
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


- (void) fetchvote{
    NSLog(@"Fetching vote");
    NSEntityDescription *entityDesc = [NSEntityDescription
                                       entityForName:@"Votes" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fbId == %@) AND (pid == %ld)", self.fbId, self.pid];
    [request setPredicate:predicate];
    NSArray *vote = [self.context executeFetchRequest:request error:&error];
    // Vote found
    if(vote.count > 0){
        // Vote exists to things with it
        self.voteObject = [vote objectAtIndex:0];
    }
    // Vote not found, needs to be created
    else{
        NSManagedObject *newVote;
        newVote = [NSEntityDescription insertNewObjectForEntityForName:@"Votes" inManagedObjectContext:self.context];
        [newVote setValue:self.fbId forKey:@"fbId"];
        [newVote setValue:self.pid forKey:@"pid"];
        [newVote setValue: FALSE forKey:@"voted"];
        NSError *error;
        [self.context save:&error];
        [self.voteObject setValue:self.fbId forKey:@"fbId"];
        [self.voteObject setValue:self.pid forKey:@"pid"];
        [self.voteObject setValue: FALSE forKey:@"voted"];
    }
}

- (void) fetchItem
{
    NSEntityDescription *entityDesc = [NSEntityDescription
                                       entityForName:@"Products" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %ld", [self.pid longValue]];
    [request setPredicate:predicate];
    NSArray *product = [self.context executeFetchRequest:request error:&error];
    if(product.count > 0){
        // Item was found
        self.item = [product objectAtIndex:0];
        NSURL *imageUrl = [NSURL URLWithString:[self.item valueForKey: @"image"]];
        [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                [self.shoeImage setImage:[[UIImage alloc] initWithData:data]];
                if(![self.voteObject valueForKey:@"voted"]){
                    [self.noButton setEnabled:true];
                    [self.yesButton setEnabled:true];
                }
            }
        }];
    }else{
        NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/product/%ld", [self.pid longValue]];
        NSURL * fetchURL = [NSURL URLWithString:url];
        NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSOperationQueue * queue = [[NSOperationQueue alloc]init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            self.item = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            NSURL *imageUrl = [NSURL URLWithString:[self.item valueForKey: @"image"]];
            [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, NSData *data) {
                if (succeeded) {
                    [self.shoeImage setImage:[[UIImage alloc] initWithData:data]];
                    if(![self.voteObject valueForKey:@"voted"]){
                        [self.noButton setEnabled:true];
                        [self.yesButton setEnabled:true];
                    }
                }
            }];
        }];
    }
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
    [self.noButton setEnabled:false];
    [self.yesButton setEnabled:false];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    [self fetchvote];
    // Do any additional setup after loading the view.
    // Check if item has already been set (coming from votes view)
    if([self.item count] > 0){
        NSURL *imageUrl = [NSURL URLWithString:[self.item valueForKey: @"image"]];
        [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                [self.shoeImage setImage:[[UIImage alloc] initWithData:data]];
                if(![self.voteObject valueForKey:@"voted"]){
                    [self.noButton setEnabled:true];
                    [self.yesButton setEnabled:true];
                }
            }
        }];
    }
    // If item is not set it needs to be from db or server
    else
    {
        [self fetchItem];
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
