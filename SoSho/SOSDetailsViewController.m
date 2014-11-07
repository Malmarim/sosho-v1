//
//  SOSDetailsViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 25.7.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSDetailsViewController.h"
#import "SOSAppDelegate.h"
#import "SoShoStyleKit.h"
#import "SOSLabel.h"

#import "SOSFriendListViewController.h"

@interface SOSDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIView *shoeView;

@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIImageView *shoe;
@property (weak, nonatomic) IBOutlet UIImageView *info;
@property (weak, nonatomic) IBOutlet UIButton *shopButton;
@property (weak, nonatomic) IBOutlet UIButton *askButton;
@property (weak, nonatomic) IBOutlet UIView *tabBar;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) UIFont *font;

@property (weak, nonatomic) IBOutlet UIImageView *likes;
//@property (weak, nonatomic) IBOutlet UIImageView *dislikes;

@property (weak, nonatomic) IBOutlet SOSLabel *designer;
@property (weak, nonatomic) IBOutlet SOSLabel *product;

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UIButton *messagesButton;
//@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *yesVotes;
@property (weak, nonatomic) IBOutlet UILabel *noVotes;

@property NSString *url;

@end

@implementation SOSDetailsViewController


- (IBAction)buttonTouched:(id)sender {
    
    [self resizeButton:(UIButton *)sender];
    
    if((UIButton * )sender == self.back){
        [self dismissViewControllerAnimated:YES completion:nil];
        [self sendEvent:@"Closing info"];
    }
    else if((UIButton * )sender == self.shopButton){
        [self sendEvent:@"Store (from info)"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
    }else if((UIButton *)sender == self.askButton){
        // ask a friend
        [self sendEvent:@"Ask a friend (from info)"];
    }else if((UIButton *)sender == self.homeButton){
        [self sendEvent:@"Home (from info)"];
    }else if((UIButton *)sender == self.wishlistButton){
        [self sendEvent:@"Wishlist (from info)"];
    }else if((UIButton *)sender == self.messagesButton){
        [self sendEvent:@"Messages (from info)"];
    }
}

- (void) resizeButton:(UIButton *)button
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         button.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     }];
    [UIView animateWithDuration:0.5
                     animations:^{
                         button.transform = CGAffineTransformMakeScale(1, 1);
                     }];
}

- (void)sendEvent:(NSString *) label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:label          // Event label
                                                           value:nil] build]];    // Event value
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) fetchItem
{
    NSEntityDescription *entityDesc = [NSEntityDescription
                                       entityForName:@"Products" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %d", [self.pid integerValue]];
    [request setPredicate:predicate];
    NSArray *product = [self.context executeFetchRequest:request error:&error];
    if(product.count > 0){
        NSLog(@"Item found");
        self.item = [product objectAtIndex:0];
        [self presentProduct];
    }else{
        NSLog(@"Item not found");
        // Item not found on phone, need to check online
        NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/product/%ld", [self.pid longValue]];
        NSURL * fetchURL = [NSURL URLWithString:url];
        NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSOperationQueue * queue = [[NSOperationQueue alloc]init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
            if(!error){
                NSLog(@"Item fetched");
                NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
                NSDictionary *object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                NSURL *imageUrl = [NSURL URLWithString:[object valueForKey: @"image"]];
                [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, NSData *data) {
                    if (succeeded) {
                        UIImage *shoeImage = [[UIImage alloc] initWithData:data];
                        [self.shoe setImage:shoeImage];
                        UIImage *shopImage = [UIImage imageNamed:@"shop-online"];
                        UIImage *shopped = [self drawPrice:[object valueForKey:@"price"] inImage:shopImage at:CGPointMake(380, 26)];
                        [self.shopButton setImage:shopped forState:UIControlStateNormal];
                        //[self.name setText:[object valueForKey:@"name"]];
                        //[self.store setText:[object valueForKey:@"store"][@"name"]];
                        self.url = [object valueForKey:@"url"];
                    }
                }];
            }
            else{
                NSLog(@"Fetch failed :%@", error.localizedDescription);
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

-(UIImage *) drawWithText:(NSString *)text inImage:(UIImage *) image at:(CGPoint) point
{
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    NSDictionary *attrs = @{ NSFontAttributeName: [UIFont fontWithName:@"Lato-Regular" size:50], NSForegroundColorAttributeName: self.textColor};
    [text drawInRect:CGRectIntegral(rect) withAttributes:attrs];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
    //NSString *fontName = @"PlayfairDisplay-Bold";
    
    NSDictionary *attrs = @{ NSFontAttributeName: [UIFont fontWithName:fontName size:36], NSForegroundColorAttributeName: [UIColor whiteColor]};
    [price drawInRect:CGRectIntegral(rect) withAttributes:attrs];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) presentProduct
{

    NSURL *imageUrl = [NSURL URLWithString:[self.item valueForKey: @"image"]];
    [self downloadImageWithURL:imageUrl completionBlock:^(BOOL succeeded, NSData *data) {
        if (succeeded) {
            UIImage *shoeImage = [[UIImage alloc] initWithData:data];
            [self.shoe setImage:shoeImage];
            //UIImage *shopImage = [UIImage imageNamed:@"shop-online"];
            UIImage *shopImage = [SoShoStyleKit imageOfBTNBuyOnline];
            UIImage *shopped = [self drawPrice:[self.item valueForKey:@"price"] inImage:shopImage at:CGPointMake(370, 25)];
            [self.shopButton setImage:shopped forState:UIControlStateNormal];
            
            NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc] initWithString:[[self.item valueForKey:@"name"]uppercaseString]];
            [attr1 addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attr1.length)];
            self.product.attributedText = attr1;
            
            NSMutableAttributedString *attr2 = [[NSMutableAttributedString alloc] initWithString:[[self.item valueForKey:@"store"]uppercaseString]];
            [attr2 addAttribute:NSKernAttributeName value:@(4.0) range:NSMakeRange(0, attr2.length)];
            self.designer.attributedText = attr2;

            [self.product sizeToFit];
            [self.designer sizeToFit];
            self.url = [self.item valueForKey:@"url"];
        }
    }];
}


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Details";
    
    // Do any additional setup after loading the view.
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    self.font = [UIFont fontWithName:@"Lato-Regular" size:12];
    self.textColor = [UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1];
    [self.designer setFont:self.font];
    [self.designer setTextColor:self.textColor];
    [self.product setFont:self.font];
    [self.product setTextColor:self.textColor];
    if([self.item valueForKey:@"image"] != nil){
        NSLog(@"Item set, using presets");
        [self presentProduct];
    }else{
        NSLog(@"Item not set, fetching item");
        [self fetchItem];
    }
    
    [self.back setImage:[SoShoStyleKit imageOfBTNGoBack] forState:UIControlStateNormal];
    [self.info setImage:[SoShoStyleKit imageOfSoshoAppLogo]];
    [self.askButton setImage:[SoShoStyleKit imageOfBTNAskAFriend] forState:UIControlStateNormal];
    
    // Add a topBorder.
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, self.tabBar.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithRed: 1 green: 0.463 blue: 0.376 alpha: 1].CGColor;
    [self.tabBar.layer addSublayer:topBorder];
    
    self.shoeView.layer.borderColor = [UIColor colorWithRed:245/255 green:240/255 blue:245/255 alpha:0.5].CGColor;
    self.shoeView.layer.borderWidth = 0.5;
    self.shoeView.layer.cornerRadius = 4.0;
    self.shoeView.layer.masksToBounds = YES;
    
    [self.homeButton setImage:[SoShoStyleKit imageOfTabBarHomeActive] forState:UIControlStateNormal];
    [self.homeButton setContentMode:UIViewContentModeScaleAspectFit];
    [self.wishlistButton setImage:[SoShoStyleKit imageOfTabBarWishlistInActive] forState:UIControlStateNormal];
    [self.wishlistButton setContentMode:UIViewContentModeScaleAspectFit];
    [self.messagesButton setImage:[SoShoStyleKit imageOfTabBarMessagesInActive] forState:UIControlStateNormal];
    [self.messagesButton setContentMode:UIViewContentModeScaleAspectFit];
    //[self.moreButton setImage:[SoShoStyleKit imageOfTabBarMoreInActive] forState:UIControlStateNormal];
    //[self.moreButton setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.likes setImage:[SoShoStyleKit imageOfOne_bar_for_detail_screen]];
    //[self.dislikes setImage:[SoShoStyleKit imageOfIconInsideImageDislikes]];
    [self fetchVotes];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.destinationViewController isKindOfClass:[SOSFriendListViewController class]]){
        [segue.destinationViewController setItemUrl:[self.item valueForKey:@"image"]];
    }
}


@end
