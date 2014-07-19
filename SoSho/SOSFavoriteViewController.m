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

@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (weak, nonatomic) IBOutlet UIImageView *yesIcon;
@property (weak, nonatomic) IBOutlet UITextView *yesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noIcon;
@property (weak, nonatomic) IBOutlet UITextView *noLabel;



@property (nonatomic) long itemId;

@end

@implementation SOSFavoriteViewController

- (IBAction)buttonTouched:(id)sender {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlString]];
}

- (IBAction)askFriend:(id)sender {
    // Check if the Facebook app is installed and we can present the share dialog
//    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:[NSURL URLWithString:[self.favorite valueForKey:@"url"]] name:[self.favorite valueForKey:@"name"] caption:@"" description:@"" picture:[NSURL URLWithString:[self.favorite valueForKey:@"image"]]];

    
    
//    params.link = [NSURL URLWithString:[self.favorite valueForKey: @"url"]];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        // Present the share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
    } else {
        // Present the feed dialog
        NSLog(@"Present feed dialog");
        // Put together the dialog parameters
        params = nil;
        
//        NSString *appUrl = @"fb600087446740715";
//        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [self.favorite valueForKey: @"name"], @"name",
                                       @"", @"caption",
                                       @"", @"description",
                                       [self.favorite valueForKey: @"url"], @"link",
                                       [self.favorite valueForKey: @"image"], @"picture",
                                       nil];
        
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }

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
    
    if([defaults objectForKey:@"lastFetched"] == nil)
    {
        NSString *fbId = [defaults valueForKey:@"fbId"];
        // Fetch votes, parse them, and set them visible
        NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/getVotes/%@/%ld", fbId, self.itemId];
        NSURL * fetchURL = [NSURL URLWithString:url];
        NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSOperationQueue * queue = [[NSOperationQueue alloc]init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            NSDictionary *item = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            int yesCount = [[item valueForKey: @"yes"] intValue];
            int noCount = [[item valueForKey: @"no"] intValue];
            if(yesCount > 0){
                NSString *yesText = [NSString stringWithFormat:@"%d", yesCount];
                [self.yesLabel setText:yesText];
            }
            if(noCount > 0){
                NSString *noText = [NSString stringWithFormat:@"%d", noCount];
                [self.noLabel setText:noText];
            }
        }];
    }
}

- (void)loadItem
{
    if(self.favorite != nil){
        self.itemId = [[self.favorite valueForKey: @"id"] longValue];
        [self.name setText:[self.favorite valueForKey: @"name"]];
        NSURL *url = [NSURL URLWithString:[self.favorite valueForKey: @"image"]];
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                [self.image setImage:[[UIImage alloc] initWithData:data]];
            }
        }];
        self.urlString = [self.favorite valueForKey:@"url"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage* shareImage = [UIImage imageNamed:@"share-button.png"];
    [self.share setImage:shareImage forState:UIControlStateNormal];
    UIImage* storeImage = [UIImage imageNamed:@"store-button.png"];
    [self.store setImage:storeImage forState:UIControlStateNormal];
    UIImage* no = [UIImage imageNamed:@"no-icon.png"];
    [self.noIcon setImage:no];
    UIImage* yes = [UIImage imageNamed:@"yes-icon.png"];
    [self.yesIcon setImage:yes];
    [self loadItem];
    [self fetchVotes];
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
