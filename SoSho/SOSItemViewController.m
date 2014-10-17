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
#import "SOSItemView.h"



@interface SOSItemViewController ()

@property (weak, nonatomic) IBOutlet UIButton *dis;
@property (weak, nonatomic) IBOutlet UIButton *like;
@property (weak, nonatomic) IBOutlet UIButton *wishlist;
@property (weak, nonatomic) IBOutlet UIButton *menu;
@property (weak, nonatomic) IBOutlet UIButton *info;
@property (strong, nonatomic) IBOutlet UIButton *tempButton;
@property (weak, nonatomic) IBOutlet UIImageView *background;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UIImageView *overlay;
@property (weak, nonatomic) UIImage *overlayImage;

@property (strong, nonatomic) NSMutableArray *displayItems;
@property (strong, nonatomic) NSMutableArray *loadedItems;

@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) NSString *fbId;
@property (strong, nonatomic) NSString *pushtoken;
@property (strong, nonatomic) NSDictionary *user;
@property (nonatomic) int lastFetched;
@property (nonatomic) int viewIndex;

@property (nonatomic) BOOL hasCheckedForNew;

@property (nonatomic) CGPoint originalPoint;

@property (weak, nonatomic) IBOutlet UIView *dragView;
@property (weak, nonatomic) IBOutlet UIView *backView;


@property (nonatomic) BOOL overlayStatus;

@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *derp;

@property NSDictionary *fbUser;

@end

@implementation SOSItemViewController

- (IBAction)dragged:(UIPanGestureRecognizer *)gestureRecognizer {
    CGFloat xDistance = [gestureRecognizer translationInView:self.dragView].x;
    CGFloat yDistance = [gestureRecognizer translationInView:self.dragView].y;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.dragView.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            //CGFloat rotationStrength = MIN(xDistance / 180, 1);
            //CGFloat rotationAngel = (CGFloat) (2*M_PI * rotationStrength / 12);
            //CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 4;
            //CGFloat scale = MAX(scaleStrength, 0.93);
            //CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            //CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            //self.dragView.transform = scaleTransform;
            self.dragView.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);
            [self updateOverlay:xDistance];
            break;
        };
        case UIGestureRecognizerStateEnded: {
            if(xDistance > 150){
                [self sendEvent:@"Liked (pan)"];
                //NSLog(@"Favorited");
                [self resetPosition];
                [self addFavorite];
            }else if(xDistance < -150){
                [self sendEvent:@"Disliked (pan)"];
                //NSLog(@"Discarded");
                [self resetPosition];
                [self setNextItem];
            }else{
                [self resetViewPositionAndTransformations];
            }
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

- (void) resetPosition{
    [self.dragView setHidden:true];
    self.overlay.alpha = 0;
    self.dragView.center = self.originalPoint;
}


- (void)resetViewPositionAndTransformations
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.dragView.center = self.originalPoint;
                         self.dragView.transform = CGAffineTransformMakeRotation(0);
                         self.overlay.alpha = 0;
                     }];
}

- (void) updateOverlay:(CGFloat) distance{
    if(distance > 10){
        //right
        [self setOverlayPic:TRUE];
    }
    else if(distance < -10){
        // left
        [self setOverlayPic:FALSE];
    }
    CGFloat overlayStr = MIN(fabsf(distance)/150, 1);
    self.overlay.alpha = overlayStr;
}

- (void) setOverlayPic:(BOOL)liked
{
    if(liked != self.overlayStatus){
        self.overlayStatus = liked;
        if(liked){
            self.overlayImage = [UIImage imageNamed:@"like-icon.png"];
            //NSLog(@"Like icon set");
        }
        else{
            self.overlayImage = [UIImage imageNamed:@"dis-icon.png"];
            //NSLog(@"Dislike icon set");
        }
        [self.overlay setImage:self.overlayImage];
    }
}

/*
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
*/


- (IBAction)buttonTouched:(id)sender
{
    if((UIButton *) sender == self.like) {
        [self sendEvent:@"Liked (button)"];
        [self addFavorite];
    }else if ((UIButton *)sender == self.dis){
        [self sendEvent:@"Disliked (button)"];
        [self setNextItem];
    }
    else if((UIButton *)sender == self.wishlist){
        [self sendEvent:@"Wishlist (from item)"];
        [self performSegueWithIdentifier:@"itemtofavorites" sender:self];
    }else if((UIButton *)sender == self.menu){
        [self sendEvent:@"Options"];
        // Open menu
    }else if((UIButton *)sender == self.info){
        [self sendEvent:@"Info"];// Open info
    }else if((UIButton *)sender == self.tempButton) {
//        FBRequest* friendsRequest = [FBRequest requestForMyFriends];
//        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
//                                                      NSDictionary* result,
//                                                      NSError *error) {
//            NSArray* friends = [result objectForKey:@"data"];
//            NSLog(@"Found: %i friends", friends.count);
//            for (NSDictionary<FBGraphUser>* friend in friends) {
//                NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
//            }
//        }];
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:
         ^(FBRequestConnection *connection, id<FBGraphUser> friends, NSError *error)
         {
             if(!error){
                NSLog(@"results = %@", friends);
             }
         }
         ];
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


- (IBAction)unwindToItem:(UIStoryboardSegue *)unwindSegue
{
    
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [[[UIAlertView alloc] initWithTitle:title
                                    message:text
                                   delegate:self
                          cancelButtonTitle:@"OK!"
                          otherButtonTitles:nil] show];
    }];
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
            NSLog(@"Checking for new shoes");
            self.hasCheckedForNew = TRUE;
            [self fetchNewCount];
        }
        else{
            NSLog(@"No new shoes to be found");
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
    NSLog(@"Loading items");
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
    self.displayItems = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    NSLog(@"%d items loaded", [self.displayItems count]);
    [self shuffle];
    //[self loadDisplayItem];
}

-(void) shuffle
{
    NSUInteger count = [self.displayItems count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSInteger remainingCount = count - i;
        NSInteger exchangeIndex = i + arc4random_uniform(remainingCount);
        [self.displayItems exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
    NSLog(@"Shuffle completed");
    [self loadDisplayItem];
}

// Set up item to display from array
-(void) loadDisplayItem
{
    
    if([self.displayItems count] > 0){
        NSDictionary *item = [self.displayItems objectAtIndex:(NSUInteger)self.viewIndex];
        NSURL *url = [NSURL URLWithString:[item valueForKey: @"image"]];
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                [self loadBackgroundImage];
                //NSLog(@"Image found");
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.image setImage:image];
                    [self.dragView setHidden:false];
                }];
            }else{
                // If unable to load image, show next product instead
                NSLog(@"Image not found, setting next");
                [self setNextItem];
            }
        }];
    }else{
        NSLog(@"No shoes found");
        //[self showMessage:@"No shoes in selected category found, fetching more" withTitle:@"No matchies"];
        //[self fetchNewCount];
    }
}

- (void) loadBackgroundImage
{
    int background = self.viewIndex+1;
    
    if([self.displayItems count] > background){
        NSDictionary *item = [self.displayItems objectAtIndex:(NSUInteger)background];
        NSURL *url = [NSURL URLWithString:[item valueForKey: @"image"]];
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                //NSLog(@"Image found");
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.background setImage:image];
                }];
            }else{
                // If unable to load image, show next product instead
                NSLog(@"Set placeholder");
            }
        }];
    }
}

- (void) downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [[UIImage alloc] initWithData:data];
            if(image == nil)
                completionBlock(NO, image);
            else
                completionBlock(YES, image);
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
    
    self.screenName = @"Item";
    
    self.derp = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    [self.view addGestureRecognizer:self.derp];
    
    
    self.overlayImage = [UIImage imageNamed:@"dis-icon.png"];
    [self.overlay setImage:self.overlayImage];
    self.overlay.alpha = 0;
    self.overlayStatus = false;
    
    self.dragView.layer.borderColor = [UIColor colorWithRed:245/255 green:240/255 blue:245/255 alpha:0.5].CGColor;
    self.backView.layer.borderColor = [UIColor colorWithRed:245/255 green:240/255 blue:245/255 alpha:0.5].CGColor;
    self.dragView.layer.borderWidth = 0.5;
    self.backView.layer.borderWidth = 0.5;
    
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
