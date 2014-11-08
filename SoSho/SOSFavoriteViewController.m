//
//  SOSFavoritezViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 10.6.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSFavoriteViewController.h"
#import "SOSAppDelegate.h"
#import "SOSLabel.h"
#import "SoShoStyleKit.h"
#import "SOSFriendListViewController.h"

@interface SOSFavoriteViewController ()


@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIButton *store;
@property (weak, nonatomic) IBOutlet UIButton *share;
@property (weak, nonatomic) IBOutlet UIButton *wishlist;
@property (weak, nonatomic) IBOutlet SOSLabel *designer;
@property (weak, nonatomic) IBOutlet SOSLabel *product;
@property (weak, nonatomic) IBOutlet UIView *tabBar;

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UIButton *messagesButton;
@property (weak, nonatomic) IBOutlet UIImageView *logo;

@property (weak, nonatomic) IBOutlet UIView *background;

@property (strong, nonatomic) NSString *urlString;

@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (weak, nonatomic) IBOutlet UIImageView *yesIcon;
@property (weak, nonatomic) IBOutlet UILabel *noVotes;
@property (weak, nonatomic) IBOutlet UILabel *yesVotes;

@property NSNumber *pid;


@end

@implementation SOSFavoriteViewController

- (void)sendEvent:(NSString *) label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:label          // Event label
                                                           value:nil] build]];    // Event value
}

- (IBAction)buttonTouched:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.favorite valueForKey:@"url"]]];
    [self sendEvent:@"Store (favorite)"];
}

- (IBAction)askFriend:(id)sender {
    
    [self sendEvent:@"Ask a friend"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fbId = [defaults valueForKey:@"fbId"];
    //NSURL *shareUrl = [NSURL URLWithString:self.urlString];
    NSString *foo = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/getApplink/%@/%ld", fbId, [self.pid longValue]];
    NSURL *shareUrl = [NSURL URLWithString:foo];
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:[self.favorite valueForKey:@"url"]];
    params.name = @"Name";
    params.caption = @"Caption";
    params.picture = [NSURL URLWithString:[self.favorite valueForKey:@"image"]];
    params.linkDescription = @"Check it out.";
    if ([FBDialogs canPresentMessageDialogWithParams:params]) {
        // Enable button or other UI to initiate launch of the Message Dialog
        [FBDialogs presentMessageDialogWithLink:shareUrl
                                        handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                            if(error) {
                                                // An error occurred, we need to handle the error
                                                // See: https://developers.facebook.com/docs/ios/errors
                                                NSLog(@"Error messaging link: %@", error);
                                            } else {
                                                // Success
                                                NSLog(@"result %@", results);
                                            }
                                        }];
    }else{
        [self showMessage:@"Facebook Messenger is required for sharing!" withTitle:@"Error"];
    }
}

- (IBAction)unwindToFavorite:(UIStoryboardSegue *)unwindSegue
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
- (void) fetchVotes
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fbId = [defaults valueForKey:@"fbId"];
    // Fetch votes, parse them, and set them visible
    NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/votes/%@/%ld", fbId, [self.pid longValue]];
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            NSLog(@"Votes fetched");
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            NSDictionary *item = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            NSString *yes = [NSString stringWithFormat:@"%@",[item valueForKey:@"yesVote"]];
            NSString *no = [NSString stringWithFormat:@"%@",[item valueForKey:@"noVote"]];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.yesLabel setText:yes];
                [self.noLabel setText:no];
                self.urlString = [item valueForKey:@"applink"];
            }];
        }
    }];
}
*/

// Fetch votes given to this shoe
- (void) fetchVotes
{
    // Fetch votes, parse them, and set them visible
    NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/itemVotes/%ld", [self.pid longValue]];
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            NSLog(@"No fetching errors");
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            if(jsonData != nil){
                NSDictionary *item = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                NSString *yes = [NSString stringWithFormat:@"%@",[item valueForKey:@"yesVote"]];
                NSString *no = [NSString stringWithFormat:@"%@",[item valueForKey:@"noVote"]];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.yesVotes setText:yes];
                    [self.noVotes setText:no];
                }];
            }
            else{
                NSLog(@"Json null");
            }
        }else{
            NSLog(@"No votes");
        }
    }];
}

-(UIImage *) drawPrice:(NSString *)text inImage:(UIImage *) image at:(CGPoint) point
{
    UIGraphicsBeginImageContext(image.size);
    
    //NSMutableAttributedString *price = [[NSMutableAttributedString alloc] initWithString:text];
    //[price addAttribute:NSKernAttributeName value:@(1.4) range:NSMakeRange(0, 9)];
    
    NSString *euro = @"€";
    NSMutableString *price = [text mutableCopy];
    
    if([price rangeOfString:euro].location==NSNotFound){
        price = [NSMutableString stringWithFormat:@"%@%@", text, euro];
    }
    
    [image drawInRect:CGRectMake(0,0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    
    NSString *fontName = @"Lato-Black";
    
    NSDictionary *attrs = @{ NSFontAttributeName: [UIFont fontWithName:fontName size:36], NSForegroundColorAttributeName: [UIColor whiteColor]};
    [price drawInRect:CGRectIntegral(rect) withAttributes:attrs];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)loadItem
{
    if([self.favorite valueForKey:@"image"] != nil){
        self.pid = [self.favorite valueForKey: @"id"];
        UIImage *shopped = [self drawPrice:[self.favorite valueForKey:@"price"] inImage:[SoShoStyleKit imageOfBTNBuyOnline] at:CGPointMake(370, 25)];
        [self.store setImage:shopped forState:UIControlStateNormal];
        NSURL *url = [NSURL URLWithString:[self.favorite valueForKey: @"image"]];
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                //UIImage *img = [[UIImage alloc] initWithData:data];
                //UIImage *img2 = [self drawWithText:[self.favorite valueForKey:@"store"] inImage:img at:CGPointMake(0, 0)];
                //UIImage *img3 = [self drawWithText:[self.favorite valueForKey:@"name"] inImage:img2 at:CGPointMake(0, 50)];
                [self.image setImage:[[UIImage alloc] initWithData:data]];
            }
        }];
        
        NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc] initWithString:[[self.favorite valueForKey:@"name"]uppercaseString]];
        [attr1 addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attr1.length)];
        self.product.attributedText = attr1;
        
        NSMutableAttributedString *attr2 = [[NSMutableAttributedString alloc] initWithString:[[self.favorite valueForKey:@"store"]uppercaseString]];
        [attr2 addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attr2.length)];
        self.designer.attributedText = attr2;

        [self.product sizeToFit];
        [self.designer sizeToFit];
        self.urlString = [self.favorite valueForKey:@"url"];
    }else{
        // We came here in a different way
        NSEntityDescription *entityDesc = [NSEntityDescription
                                           entityForName:@"Favorites" inManagedObjectContext:self.context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSError *error;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %ld", [self.pid longValue]];
        [request setPredicate:predicate];
        NSArray *product = [self.context executeFetchRequest:request error:&error];
        if(product.count > 0){
            //NSLog(@"Item found");
            self.favorite = [product objectAtIndex:0];
            UIImage* storeImage = [UIImage imageNamed:@"shop-online.png"];
            UIImage *shopped = [self drawPrice:[self.favorite valueForKey:@"price"] inImage:storeImage at:CGPointMake(380, 26)];
            [self.store setImage:shopped forState:UIControlStateNormal];
            NSURL *url = [NSURL URLWithString:[self.favorite valueForKey: @"image"]];
            [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, NSData *data) {
                if (succeeded) {
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    //UIImage *img2 = [self drawWithText:[self.favorite valueForKey:@"store"] inImage:img at:CGPointMake(0, 0)];
                    //UIImage *img3 = [self drawWithText:[self.favorite valueForKey:@"name"] inImage:img2 at:CGPointMake(0, 50)];
                    [self.image setImage:img];
                }
            }];
            NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc] initWithString:[[self.favorite valueForKey:@"name"]uppercaseString]];
            [attr1 addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attr1.length)];
            self.product.attributedText = attr1;
            
            NSMutableAttributedString *attr2 = [[NSMutableAttributedString alloc] initWithString:[[self.favorite valueForKey:@"store"]uppercaseString]];
            [attr2 addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attr2.length)];
            self.designer.attributedText = attr2;

            [self.product sizeToFit];
            [self.designer sizeToFit];
            self.urlString = [self.favorite valueForKey:@"url"];
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
                    self.favorite = object;
                    UIImage* storeImage = [UIImage imageNamed:@"shop-online.png"];
                    UIImage *shopped = [self drawPrice:[self.favorite valueForKey:@"price"] inImage:storeImage at:CGPointMake(380, 26)];
                    [self.store setImage:shopped forState:UIControlStateNormal];
                    NSURL *url = [NSURL URLWithString:[self.favorite valueForKey: @"image"]];
                    [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, NSData *data) {
                        if (succeeded) {
                            UIImage *img = [[UIImage alloc] initWithData:data];
                            /*UIImage *img2 = [self drawWithText:[self.favorite valueForKey:@"store"] inImage:img at:CGPointMake(0, 0)];
                            UIImage *img3 = [self drawWithText:[self.favorite valueForKey:@"name"] inImage:img2 at:CGPointMake(0, 50)];*/
                            [self.image setImage:img];
                        }
                    }];
                    NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc] initWithString:[[self.favorite valueForKey:@"name"]uppercaseString]];
                    [attr1 addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attr1.length)];
                    self.product.attributedText = attr1;
                    
                    NSMutableAttributedString *attr2 = [[NSMutableAttributedString alloc] initWithString:[[self.favorite valueForKey:@"store"]uppercaseString]];
                    [attr2 addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attr2.length)];
                    self.designer.attributedText = attr2;

                    [self.product sizeToFit];
                    [self.designer sizeToFit];
                    self.urlString = [self.favorite valueForKey:@"url"];
                }
                else{
                    NSLog(@"Fetch failed :%@", error.localizedDescription);
                }
            }];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Favorite";
    [self.share setImage:[SoShoStyleKit imageOfBTNAskAFriend] forState:UIControlStateNormal];
    //[self.noIcon setImage:[SoShoStyleKit imageOfIconInsideImageDislikes]];
    [self.yesIcon setImage:[SoShoStyleKit imageOfOne_bar_for_detail_screen]];
    [self.wishlist setImage:[SoShoStyleKit imageOfBTNGoBack] forState:UIControlStateNormal];
    
    // Add a topBorder.
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, self.tabBar.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithRed: 1 green: 0.463 blue: 0.376 alpha: 1].CGColor;
    [self.tabBar.layer addSublayer:topBorder];
    
    self.background.layer.borderColor = [UIColor colorWithRed:245/255 green:240/255 blue:245/255 alpha:0.5].CGColor;
    self.background.layer.borderWidth = 0.5;
    self.background.layer.cornerRadius = 4.0;
    self.background.layer.masksToBounds = YES;
    
    [self.homeButton setImage:[SoShoStyleKit imageOfTabBarHomeInActive] forState:UIControlStateNormal];
    [self.homeButton setContentMode:UIViewContentModeScaleAspectFit];
    [self.wishlistButton setImage:[SoShoStyleKit imageOfTabBarWishlistActive] forState:UIControlStateNormal];
    [self.wishlistButton setContentMode:UIViewContentModeScaleAspectFit];
    [self.messagesButton setImage:[SoShoStyleKit imageOfTabBarMessagesInActive] forState:UIControlStateNormal];
    [self.messagesButton setContentMode:UIViewContentModeScaleAspectFit];
    //[self.moreButton setImage:[SoShoStyleKit imageOfTabBarMoreInActive] forState:UIControlStateNormal];
    //[self.moreButton setContentMode:UIViewContentModeScaleAspectFit];
    [self.logo setImage:[SoShoStyleKit imageOfSoshoAppLogo]];
    [self loadItem];
    [self fetchVotes];
    
    UIFont *font = [UIFont fontWithName:@"Lato-Regular" size:12];
    UIColor *color = [UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1];
    [self.designer setFont:font];
    [self.designer setTextColor:color];
    [self.product setFont:font];
    [self.product setTextColor:color];
    
    UIColor* heartColor = [UIColor colorWithRed: 0.216 green: 0.706 blue: 0.58 alpha: 1];
    UIColor* dislikeColor = [UIColor colorWithRed: 0.988 green: 0.486 blue: 0.408 alpha: 1];
    
    [self.yesVotes setTextColor:heartColor];
    [self.noVotes setTextColor:dislikeColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];
    
    return urlWasHandled;
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.destinationViewController isKindOfClass:[SOSFriendListViewController class]]){
        [segue.destinationViewController setItemUrl:[self.favorite valueForKey:@"image"]];
    }
    else{
        [self sendEvent:@"Wishlist (from favorite)"];
    }
}

@end
