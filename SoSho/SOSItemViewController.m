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

@interface SOSItemViewController ()

@property (weak, nonatomic) IBOutlet UIButton *favorites;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logout;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (strong, nonatomic) NSArray *displayItems;
@property (strong, nonatomic) NSMutableArray *loadedItems;

@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) NSString *fbId;
@property (nonatomic) int lastViewed;
@property (nonatomic) int lastFetched;
@property (nonatomic) int viewIndex;

@property (nonatomic) BOOL hasCheckedForNew;

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
    if((UIBarButtonItem *)sender == self.logout){
    // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            [FBSession.activeSession closeAndClearTokenInformation];
        }
    }
    else if((UIButton *)sender == self.favorites){
    }
}

-(void) fetchFacebookId
{
    
}

-(void) fetchNewCount
{
    NSString *url = [NSString stringWithFormat:@"http://sosho-service.herokuapp.com/newCount/%d", self.lastFetched];
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
        NSDictionary *item = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        int newCount = [[item valueForKey: @"newCount"] intValue];
        if(newCount > 0){
            self.hasCheckedForNew = FALSE;
            [self fetchData];
        }
        else{
            [self loadItems];
        }
    }];
}

// Fetch itemdata asynchroniously
- (void) fetchData
{
    NSString *url = [NSString stringWithFormat:@"http://sosho-service.herokuapp.com/new/%d", self.lastFetched];
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
        self.loadedItems = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        [self saveItems];
    }];
}

// Load info regarding last fetched item and last viewed item
- (void) loadPresets
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"lastViewed"] == nil){
        self.lastViewed = 0;
        [defaults setInteger:self.lastViewed forKey:@"lastViewed"];
        [defaults synchronize];
    }
    else
    {
        self.lastViewed = (int)[defaults integerForKey:@"lastViewed"];
    }
    if([defaults objectForKey:@"lastFetched"] == nil){
        self.lastFetched = 0;
        [defaults setInteger:self.lastFetched forKey:@"lastFetched"];
        [defaults synchronize];
    }
    else
    {
        self.lastFetched = (int)[defaults integerForKey:@"lastFetched"];
    }
    
    if([defaults objectForKey:@"fbId"] == nil)
    {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *aUser, NSError *error) {
             if (!error) {
                 //NSLog(@"FBID fetched as %@",[aUser objectForKey:@"id"]);
                 self.fbId = [aUser objectForKey:@"id"];
                 // name = [aUser objectForKey:@"name"];
                 //
                 [defaults setValue:self.fbId forKey:@"fbId"];
                 [defaults synchronize];
                 //NSLog(@"FBID set as %@", self.fbId);
                 
             }
         }];
    }
    else
    {
        
        [defaults setValue:nil forKey:@"fbId"];
        [defaults synchronize];
        //self.fbId =[defaults valueForKey:@"fbId"];
        //NSLog(@"FBID loaded: %@", self.fbId);
    }
}

// Save info regarding last fetched item
- (void) saveLastFetched
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.lastFetched forKey:@"lastFetched"];
    [defaults synchronize];
}

// Save info regarding last viewed item
- (void) saveLastViewed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.lastViewed forKey:@"lastViewed"];
    [defaults synchronize];
}

// Post new favorite to the server
-(void) postNewFavorite:(long) pid
{
   /*
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://sosho-service/addFavorite/"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSString *params = [[NSString alloc] initWithFormat:@"fbId=%@&id=%ld", self.fbId, pid];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error)
            NSLog(@"All is good");
        else
            NSLog(@"Something went wrong");
        //NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
        //self.loadedItems = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        //[self saveItems];
    }];
    */
}

// Select the next item from array
- (void) setNextItem
{
    if((self.viewIndex+1) < [self.displayItems count])
    {
        NSDictionary *item = [self.displayItems objectAtIndex:(NSUInteger)self.viewIndex];
        self.lastViewed = [[item valueForKey: @"id"] intValue];
        [self saveLastViewed];
        self.viewIndex++;
        [self loadDisplayItem];
    }
    else
    {
        if(!self.hasCheckedForNew){
            NSLog(@"Checking for new shoes");
            self.hasCheckedForNew = TRUE;
            [self.name setText:@"Checking for more shoes"];
            [self.name setHidden:FALSE];
            [self fetchNewCount];
        }
        else{
            NSLog(@"No new shoes to be found");
            [self.name setText:@"No new items found"];
            [self.name setHidden:FALSE];
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
        NSError *error;
        [self.context save:&error];
        [self postNewFavorite:[[item valueForKey: @"id"] longValue]];
        [self setNextItem];
    }
    //else{}
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
    [request setEntity:entityDesc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"id > %d", self.lastViewed];
    [request setPredicate:predicate];
    NSError *error;
    self.displayItems = [self.context executeFetchRequest:request error:&error];
    [self.name setText:@""];
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
                //[self.name setText:[item valueForKey: @"name"]];
                [self.name setHidden:TRUE];
                [self.image setImage:[[UIImage alloc] initWithData:data]];
            }
        }];
    }
    //else{}
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
    UIImage* myImage = [UIImage imageNamed:@"footer.jpg"];
    [self.favorites setImage:myImage forState:UIControlStateNormal];
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
