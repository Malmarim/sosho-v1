//
//  SOSItemViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 16.5.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSItemViewController.h"
#import "FacebookSDK/FacebookSDK.h"
#import "SOSAppDelegate.h"
#import "SOSVoteViewController.h"
#import "SOSDetailsViewController.h"

@interface SOSItemViewController ()

@property (weak, nonatomic) IBOutlet UIButton *dis;
@property (weak, nonatomic) IBOutlet UIButton *like;
@property (weak, nonatomic) IBOutlet UIButton *wishlist;
@property (weak, nonatomic) IBOutlet UIButton *menu;
@property (weak, nonatomic) IBOutlet UIButton *info;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@property (strong, nonatomic) NSArray *displayItems;
@property (strong, nonatomic) NSMutableArray *loadedItems;

@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) NSString *fbId;
@property (strong, nonatomic) NSString *pushtoken;
@property (strong, nonatomic) NSDictionary *user;
@property (nonatomic) int lastFetched;
@property (nonatomic) int viewIndex;

@property (nonatomic) BOOL hasCheckedForNew;

@property NSDictionary *fbUser;

@end

@implementation SOSItemViewController

- (IBAction)swipeRight:(UISwipeGestureRecognizer *)sender {
    if(sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self addFavorite];
    }
}

- (IBAction)swipeLeft:(UISwipeGestureRecognizer *)sender {
    if(sender.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self setNextItem];
    }
}

- (IBAction)buttonTouched:(id)sender
{
    if((UIButton *) sender == self.like) {
        [self addFavorite];
    }else if ((UIButton *)sender == self.dis){
        [self setNextItem];
    }
    else if((UIButton *)sender == self.wishlist){
        [self performSegueWithIdentifier:@"itemtofavorites" sender:self];
    }else if((UIButton *)sender == self.menu){
            // Open menu
    }else if((UIButton *)sender == self.info){
            // Open info
    }
}

- (IBAction)unwindToItem:(UIStoryboardSegue *)unwindSegue
{
    
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

// Load info regarding last fetched item and last viewed item
- (void) loadPresets
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"lastFetched"] == nil){
        self.lastFetched = 0;
        [defaults setInteger:self.lastFetched forKey:@"lastFetched"];
        [defaults synchronize];
    }
    else
    {
        self.lastFetched = (int)[defaults integerForKey:@"lastFetched"];
    }
    
    if([defaults objectForKey:@"fbId"] == nil || [defaults objectForKey:@"location"] == nil)
    {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *aUser, NSError *error) {
             if (!error) {
                 self.user = aUser;
                 self.fbId = [aUser objectForKey:@"id"];
                 // location = objectForKey:@"location"["name"]
                 // birthday = objectForKey:@"birthday"
                 // gender = objectForKey:@"gender"
                 /*
                 for(NSString *key in aUser){
                     NSLog(@"Key: %@, Value: %@", key, [aUser valueForKey:key]);
                 }
                 */
                 NSLog(@"Location = %@", [self.user objectForKey:@"location"][@"name"]);
                 [defaults setValue:self.fbId forKey:@"fbId"];
                 [defaults setValue:[self.user objectForKey:@"location"][@"name"] forKey:@"location"];
                 [defaults synchronize];
                 self.pushtoken = [defaults valueForKey:@"pushtoken"];
                 //Create new user with fbdata and pushtoken
                 [self postUserData];
             }
         }];
    }
    else
    {
        self.fbId = [defaults valueForKey:@"fbId"];
    }
    if([defaults objectForKey:@"category"] == nil){
        [defaults setObject:@"All" forKey:@"category"];
        [defaults synchronize];
    }
}

-(void) fetchNewCount
{
    NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/newCount/%d", self.lastFetched];
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            NSDictionary *item = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            if(!error){
                int newCount = [[item valueForKey: @"newCount"] intValue];
                if(newCount > 0){
                    self.hasCheckedForNew = FALSE;
                    [self fetchData];
                }
                else{
                    [self loadItems];
                }
            }else{
                [self loadItems];
            }
            
        }else{
            //NSLog(@"Unable to fetch count: %@", error.localizedDescription);
            [self showMessage:@"Unable to find new items, please try again later" withTitle:@"Error"];
            [self loadItems];
        }
    }];
}

// Fetch itemdata asynchroniously
- (void) fetchData
{
    NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/new/%d", self.lastFetched];
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            self.loadedItems = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            [self saveItems];
        }else{
           //NSLog(@"Unable to fetch items: %@", error.localizedDescription);
            [self showMessage:@"Unable to find new items, please try again later" withTitle:@"Error"];
            [self loadItems];
        }
    }];
}

// Save info regarding last fetched item
- (void) saveLastFetched
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.lastFetched forKey:@"lastFetched"];
    [defaults synchronize];
}

// Create a new user with fbId and pushtoken
-(void) postUserData
{
    if(self.pushtoken != nil){
        NSString *url = @"http://soshoapp.herokuapp.com/userData";
        NSURL * fetchURL = [NSURL URLWithString:url];
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSString *params = [[NSString alloc] initWithFormat:@"fbId=%@&pushtoken=%@&first_name=%@&last_name=%@&gender=%@&email=%@&location=%@&birthday=%@", self.fbId, self.pushtoken, [self.user valueForKey:@"first_name"], [self.user valueForKey:@"last_name"], [self.user valueForKey:@"gender"], [self.user valueForKey:@"email"], [self.user objectForKey:@"location"][@"name"], [self.user objectForKey:@"birthday"]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        NSOperationQueue * queue = [[NSOperationQueue alloc]init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
            if(!error){
                //NSLog(@"No Error");
            }
            else{
                //NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
    }
    else{
        NSLog(@"No pushtoken, doing testpost");
        NSString *url = @"http://soshoapp.herokuapp.com/userData";
        NSURL * fetchURL = [NSURL URLWithString:url];
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSString *params = [[NSString alloc] initWithFormat:@"fbId=%@&pushtoken=%@&first_name=%@&last_name=%@&gender=%@&email=%@&location=%@&birthday=%@", self.fbId, @"test", [self.user valueForKey:@"first_name"], [self.user valueForKey:@"last_name"], [self.user valueForKey:@"gender"], [self.user valueForKey:@"email"], [self.user objectForKey:@"location"][@"name"], [self.user objectForKey:@"birthday"]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        NSOperationQueue * queue = [[NSOperationQueue alloc]init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
            if(!error){
                //NSLog(@"Testpost: No Error");
            }
            else{
               //NSLog(@"Testpost: Error %@", error.localizedDescription);
            }
        }];
    }
}

// Post new favorite to the server
-(void) postNewFavorite:(long) pid
{
    NSString *url = @"http://soshoapp.herokuapp.com/addFavorite";
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSString *params = [[NSString alloc] initWithFormat:@"fbId=%@&id=%ld", self.fbId, pid];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            //NSLog(@"No Error");
        }
        else{
            //NSLog(@"Error");
        }
    }];
}

// Select the next item from array
- (void) setNextItem
{
    [self.context deleteObject:[self.displayItems objectAtIndex:(NSUInteger)self.viewIndex]];
    NSError *error = nil;
    if(![self.context save:&error]){
        //NSLog(@"Delete failed");
    }else{
        //NSLog(@"Delete succeeded");
    }
    
    if((self.viewIndex+1) < [self.displayItems count])
    {
        self.viewIndex++;
        [self loadDisplayItem];
    }
    else
    {
        if(!self.hasCheckedForNew){
           //NSLog(@"Checking for new shoes");
            self.hasCheckedForNew = TRUE;
            [self fetchNewCount];
        }
        else{
           //NSLog(@"No new shoes to be found");
            [self showMessage:@"No more matching shoes, try again later" withTitle:@"No matchies"];
            [self.image setImage:nil];
        }
    }
}

// Save new favorite item to file
- (void) addFavorite
{
    if([self.displayItems count] > 0){
        NSManagedObject *newFavorite;
        newFavorite = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:self.context];
        NSDictionary *item = [self.displayItems objectAtIndex:(NSUInteger)self.viewIndex];
        [newFavorite setValue: [item valueForKey: @"id"] forKey:@"id"];
        [newFavorite setValue: [item valueForKey: @"name"] forKey:@"name"];
        [newFavorite setValue: [item valueForKey: @"url"] forKey:@"url"];
        [newFavorite setValue: [item valueForKey: @"image"] forKey:@"image"];
        [newFavorite setValue: [item valueForKey: @"price"] forKey:@"price"];
        [newFavorite setValue: [item valueForKey: @"store"] forKey:@"store"];
        [newFavorite setValue: [item valueForKey: @"category"] forKey:@"category"];
        NSError *error;
        [self.context save:&error];
        [self postNewFavorite:[[item valueForKey: @"id"] longValue]];
        [self setNextItem];
    }
}

// Save items loaded from JSON to file
- (void) saveItems
{
    for(int i=0; i<[self.loadedItems count]; i++) {
        NSManagedObject *newProduct;
        newProduct = [NSEntityDescription insertNewObjectForEntityForName:@"Products" inManagedObjectContext:self.context];
        [newProduct setValue: [self.loadedItems objectAtIndex: i][@"id"] forKey:@"id"];
        [newProduct setValue: [self.loadedItems objectAtIndex: i][@"name"] forKey:@"name"];
        [newProduct setValue: [self.loadedItems objectAtIndex: i][@"url"] forKey:@"url"];
        [newProduct setValue: [self.loadedItems objectAtIndex: i][@"image"] forKey:@"image"];
        [newProduct setValue:[self.loadedItems objectAtIndex: i][@"category"][@"name"] forKey:@"category"];
        [newProduct setValue:[self.loadedItems objectAtIndex: i][@"store"][@"name"] forKey:@"store"];
        [newProduct setValue:[self.loadedItems objectAtIndex: i][@"price"] forKey:@"price"];
        NSError *error;
        [self.context save:&error];
        if(i == [self.loadedItems count]-1)
        {
            self.lastFetched = [[self.loadedItems objectAtIndex: i][@"id"] intValue];
            [self saveLastFetched];
        }
    }
    [self loadItems];
}

// Load items saved to file
- (void) loadItems
{
    self.viewIndex = 0;
    
    NSEntityDescription *entityDesc = [NSEntityDescription
                                       entityForName:@"Products" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [request setEntity:entityDesc];
    NSString *category = [defaults objectForKey:@"category"];
    if(![category isEqualToString:@"All"]){
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"category == %@", category];
        [request setPredicate:pred];
    }
     NSError *error;
    self.displayItems = [self.context executeFetchRequest:request error:&error];
    [self loadDisplayItem];
}


// Set up item to display from array
-(void) loadDisplayItem
{
    if([self.displayItems count] > 0){
        NSDictionary *item = [self.displayItems objectAtIndex:(NSUInteger)self.viewIndex];
        NSURL *url = [NSURL URLWithString:[item valueForKey: @"image"]];
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.image setImage:[[UIImage alloc] initWithData:data]];
                }];
            }else{
                // If unable to load image, show next product instead
                [self setNextItem];
            }
        }];
    }
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
    UIImage* disImage = [UIImage imageNamed:@"dis-icon.png"];
    [self.dis setImage:disImage forState:UIControlStateNormal];
    UIImage* likeImage = [UIImage imageNamed:@"like-icon.png"];
    [self.like setImage:likeImage forState:UIControlStateNormal];
    UIImage* favImage = [UIImage imageNamed:@"wishlist-button.png"];
    [self.wishlist setImage:favImage forState:UIControlStateNormal];
    UIImage* menuImage = [UIImage imageNamed:@"menu-button.png"];
    [self.menu setImage:menuImage forState:UIControlStateNormal];
    UIImage* infoImage = [UIImage imageNamed:@"info-icon.png"];
    [self.info setImage:infoImage forState:UIControlStateNormal];
    UIImage* logoImg = [UIImage imageNamed:@"small-logo.png"];
    [self.logo setImage:logoImg];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    [self loadPresets];
    [self fetchNewCount];
    self.hasCheckedForNew = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"itemtodetails"]){
        SOSDetailsViewController *dest = [segue destinationViewController];
        dest.item = [self.displayItems objectAtIndex:(NSUInteger)self.viewIndex];
    }
}


@end
