//
//  SOSFavoritezViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 10.6.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSFavoriteViewController.h"
#import "SOSAppDelegate.h"

@interface SOSFavoriteViewController ()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIButton *store;
@property (weak, nonatomic) IBOutlet UIButton *share;
@property (weak, nonatomic) IBOutlet UIButton *wishlist;

@property (strong, nonatomic) NSString *urlString;

@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (weak, nonatomic) IBOutlet UIImageView *yesIcon;
@property (weak, nonatomic) IBOutlet UILabel *yesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noIcon;
@property (weak, nonatomic) IBOutlet UILabel *noLabel;

@property NSNumber *pid;

@end

@implementation SOSFavoriteViewController

- (IBAction)buttonTouched:(id)sender {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.favorite valueForKey:@"url"]]];
}

- (IBAction)askFriend:(id)sender {
    
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

-(UIImage *) drawPrice:(NSString *)text inImage:(UIImage *) image at:(CGPoint) point
{
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    NSDictionary *attrs = @{ NSFontAttributeName: [UIFont fontWithName:@"Lato-Regular" size:30], NSForegroundColorAttributeName: [UIColor whiteColor]};
    [text drawInRect:CGRectIntegral(rect) withAttributes:attrs];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *) drawWithText:(NSString *)text inImage:(UIImage *) image at:(CGPoint) point
{
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    //NSDictionary *attrs = @{ NSFontAttributeName: [UIFont fontWithName:@"Lato-Regular" size:50], NSForegroundColorAttributeName: [UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1], NSBackgroundColorAttributeName: [UIColor whiteColor]};
    NSDictionary *attrs = @{ NSFontAttributeName: [UIFont fontWithName:@"Lato-Regular" size:50], NSForegroundColorAttributeName: [UIColor whiteColor], NSBackgroundColorAttributeName: [UIColor blackColor]};
    [text drawInRect:CGRectIntegral(rect) withAttributes:attrs];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)loadItem
{
    if([self.favorite valueForKey:@"image"] != nil){
        self.pid = [self.favorite valueForKey: @"id"];
        UIImage* storeImage = [UIImage imageNamed:@"shop-online.png"];
        UIImage *shopped = [self drawPrice:[self.favorite valueForKey:@"price"] inImage:storeImage at:CGPointMake(380, 26)];
        [self.store setImage:shopped forState:UIControlStateNormal];
        NSURL *url = [NSURL URLWithString:[self.favorite valueForKey: @"image"]];
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                UIImage *img = [[UIImage alloc] initWithData:data];
                UIImage *img2 = [self drawWithText:[self.favorite valueForKey:@"store"] inImage:img at:CGPointMake(0, 0)];
                UIImage *img3 = [self drawWithText:[self.favorite valueForKey:@"name"] inImage:img2 at:CGPointMake(0, 50)];
                [self.image setImage:img3];
            }
        }];
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
                    UIImage *img2 = [self drawWithText:[self.favorite valueForKey:@"store"] inImage:img at:CGPointMake(0, 0)];
                    UIImage *img3 = [self drawWithText:[self.favorite valueForKey:@"name"] inImage:img2 at:CGPointMake(0, 50)];
                    [self.image setImage:img3];
                }
            }];
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
                            UIImage *img2 = [self drawWithText:[self.favorite valueForKey:@"store"] inImage:img at:CGPointMake(0, 0)];
                            UIImage *img3 = [self drawWithText:[self.favorite valueForKey:@"name"] inImage:img2 at:CGPointMake(0, 50)];
                            [self.image setImage:img3];
                        }
                    }];
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
    UIImage* shareImage = [UIImage imageNamed:@"ask-friend.png"];
    [self.share setImage:shareImage forState:UIControlStateNormal];
    UIImage* no = [UIImage imageNamed:@"no-icon.png"];
    [self.noIcon setImage:no];
    UIImage* yes = [UIImage imageNamed:@"yes-icon.png"];
    [self.yesIcon setImage:yes];
    UIImage *wishImage = [UIImage imageNamed:@"wishlist-button"];
    [self.wishlist setImage:wishImage forState:UIControlStateNormal];
    [self loadItem];
    [self fetchVotes];
    //NSLog(@"Fetching vote");
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
