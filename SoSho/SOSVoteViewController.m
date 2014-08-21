//
//  SOSVoteViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 11.7.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSVoteViewController.h"
#import "SOSAppDelegate.h"
#import "SOSDetailsViewController.h"

@interface SOSVoteViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *shoeImage;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *tmpvoteObject;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation SOSVoteViewController


- (IBAction)buttonTouched:(id)sender {
    
    if((UIButton *) sender == self.yesButton){
        [self postVote:TRUE];
        //NSLog(@"Yes");
    }
    else if ((UIButton *)sender == self.noButton){
        [self postVote:FALSE];
        //NSLog(@"No");
    }
}

/*
 Posts users vote on the item online
 */
-(void)postVote:(BOOL) vote
{
    int voteInt;
    if(vote){
       //NSLog(@"Yes");
        voteInt = 1;
    }else{
       //NSLog(@"No");
        voteInt = 0;
    }
    [self.noButton setEnabled:false];
    [self.yesButton setEnabled:false];
    NSString *url = @"http://soshoapp.herokuapp.com/vote";
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSString *params = [[NSString alloc] initWithFormat:@"fbId=%@&id=%ld&vote=%d", self.fbId, [self.pid longValue], voteInt];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            // set voted true
            [self.voteObject setValue: [NSNumber numberWithBool:true] forKey:@"voted"];
            NSError *error;
            if(![self.context save:&error]){
               //NSLog(@"Vote update failed: %@", error.localizedDescription);
            }else{
               //NSLog(@"Vote updated");
            }
        }
        else{
           //NSLog(@"Vote error : %@", error.localizedDescription);
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
   //NSLog(@"Fetching vote");
    NSEntityDescription *entityDesc = [NSEntityDescription
                                       entityForName:@"Votes" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fbId = %@) AND (pid = %ld)", self.fbId, [self.pid longValue]];
    [request setPredicate:predicate];
    NSArray *vote = [self.context executeFetchRequest:request error:&error];
    // Vote found
    if(vote.count > 0){
        // Vote exists do things with it
       //NSLog(@"Vote found");
        self.voteObject = [vote objectAtIndex:0];
        if(![[self.voteObject valueForKey:@"voted"] boolValue]){
            [self.noButton setEnabled:true];
            [self.yesButton setEnabled:true];
        }
    }
    // Vote not found, needs to be created
    else{
       //NSLog(@"Vote not found");
        self.tmpvoteObject = [[NSMutableDictionary alloc] init];
        [self.tmpvoteObject setValue:self.fbId forKey:@"fbId"];
        [self.tmpvoteObject setValue:self.pid forKey:@"pid"];
        [self.tmpvoteObject setValue: [NSNumber numberWithBool:false] forKey:@"voted"];
        [self fetchItem];
    }
}

- (void) fetchItem
{
    NSEntityDescription *entityDesc = [NSEntityDescription
                                       entityForName:@"Products" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %ld", [self.pid longValue]];
    [request setPredicate:predicate];
    NSArray *product = [self.context executeFetchRequest:request error:&error];
    if(product.count > 0){
       //NSLog(@"Item found");
        // Item was found
        self.voteObject = [NSEntityDescription insertNewObjectForEntityForName:@"Votes" inManagedObjectContext:self.context];
        [self.voteObject setValue:self.fbId forKey:@"fbId"];
        [self.voteObject setValue:self.pid forKey:@"pid"];
        [self.voteObject setValue: [NSNumber numberWithBool:false] forKey:@"voted"];
        [self.voteObject setValue:[[product objectAtIndex:0] valueForKey: @"image"] forKey:@"image"];
        NSError *error;
        if(![self.context save:&error]){
           //NSLog(@"Save failed: %@", error.localizedDescription);
        }
        NSURL *imageUrl = [NSURL URLWithString:[self.voteObject valueForKey: @"image"]];
        [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                [self.shoeImage setImage:[[UIImage alloc] initWithData:data]];
               //NSLog(@"Vote: %@", [self.voteObject valueForKey:@"voted"]);
                if(![[self.voteObject valueForKey:@"voted"] boolValue]){
                    [self.noButton setEnabled:true];
                    [self.yesButton setEnabled:true];
                }
            }
        }];
    }else{
       //NSLog(@"Item not found");
        // Item not found on phone, need to check online
        NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/product/%ld", [self.pid longValue]];
        NSURL * fetchURL = [NSURL URLWithString:url];
        NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSOperationQueue * queue = [[NSOperationQueue alloc]init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
            if(!error){
               //NSLog(@"Item fetched");
                NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
                NSDictionary *object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                self.voteObject = [NSEntityDescription insertNewObjectForEntityForName:@"Votes" inManagedObjectContext:self.context];
                [self.voteObject setValue:self.fbId forKey:@"fbId"];
                [self.voteObject setValue:self.pid forKey:@"pid"];
                [self.voteObject setValue:[NSNumber numberWithBool:false] forKey:@"voted"];
                [self.voteObject setValue:[object valueForKey: @"image"] forKey:@"image"];
                NSError *error;
                if(![self.context save:&error]){
                   //NSLog(@"Save failed %@:", error.localizedDescription);
                }
                else{
                   //NSLog(@"Vote saved");
                }
                NSURL *imageUrl = [NSURL URLWithString:[self.voteObject valueForKey: @"image"]];
                [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, NSData *data) {
                    if (succeeded) {
                        [self.shoeImage setImage:[[UIImage alloc] initWithData:data]];
                        if(![[self.voteObject valueForKey:@"voted"] boolValue]){
                            [self.noButton setEnabled:true];
                            [self.yesButton setEnabled:true];
                        }
                    }
                }];
            }
            else{
               //NSLog(@"Fetch failed :%@", error.localizedDescription);
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage* shoe = [UIImage imageNamed:@"vote.png"];
    [self.backButton setImage:shoe forState:UIControlStateNormal];
    UIImage* yes = [UIImage imageNamed:@"yes-icon.png"];
    [self.yesButton setImage:yes forState:UIControlStateNormal];
    UIImage* no = [UIImage imageNamed:@"no-icon.png"];
    [self.noButton setImage:no forState:UIControlStateNormal];
    [self.noButton setEnabled:false];
    [self.yesButton setEnabled:false];
    UIImage *info = [UIImage imageNamed:@"info-icon.png"];
    [self.infoButton setImage:info forState:UIControlStateNormal];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    // Check if vote is already set
    if([self.voteObject valueForKey:@"image"] != nil){
        NSURL *imageUrl = [NSURL URLWithString:[self.voteObject valueForKey: @"image"]];
        [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                [self.shoeImage setImage:[[UIImage alloc] initWithData:data]];
               //NSLog(@"Vote: %d", [[self.voteObject valueForKey:@"voted"] boolValue]);
                if(![[self.voteObject valueForKey:@"voted"] boolValue]){
                    [self.noButton setEnabled:true];
                    [self.yesButton setEnabled:true];
                }
            }
        }];
    }
    else
    {
        [self fetchvote];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"votetodetails"])
    {
        SOSDetailsViewController *dest = segue.destinationViewController;
        dest.pid = [self.voteObject valueForKey:@"pid"];
       //NSLog(@"Set new destitnation %d", [dest.pid intValue]);
    }
}

@end
