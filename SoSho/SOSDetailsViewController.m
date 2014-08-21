//
//  SOSDetailsViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 25.7.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSDetailsViewController.h"
#import "SOSAppDelegate.h"

@interface SOSDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIImageView *shoe;
@property (weak, nonatomic) IBOutlet UIImageView *info;
@property (weak, nonatomic) IBOutlet UIButton *shopButton;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) UIFont *font;



@property (weak, nonatomic) IBOutlet UILabel *store;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property NSString *url;

@end

@implementation SOSDetailsViewController

- (IBAction)buttonTouched:(id)sender {
    if((UIButton * )sender == self.back)
        [self dismissViewControllerAnimated:YES completion:nil];
    else if((UIButton * )sender == self.shopButton)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
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
                        [self.name setText:[object valueForKey:@"name"]];
                        [self.store setText:[object valueForKey:@"store"][@"name"]];
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
    [image drawInRect:CGRectMake(0,0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    NSDictionary *attrs = @{ NSFontAttributeName: [UIFont fontWithName:@"Lato-Regular" size:30], NSForegroundColorAttributeName: [UIColor whiteColor]};
    [text drawInRect:CGRectIntegral(rect) withAttributes:attrs];
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
            UIImage *shopImage = [UIImage imageNamed:@"shop-online"];
            UIImage *shopped = [self drawPrice:[self.item valueForKey:@"price"] inImage:shopImage at:CGPointMake(380, 26)];
            [self.shopButton setImage:shopped forState:UIControlStateNormal];
            [self.name setText:[self.item valueForKey:@"name"]];
            [self.store setText:[self.item valueForKey:@"store"]];
            self.url = [self.item valueForKey:@"url"];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage* backImage = [UIImage imageNamed:@"dis-icon.png"];
    [self.back setImage:backImage forState:UIControlStateNormal];
    UIImage* infoImage = [UIImage imageNamed:@"info-icon"];
    [self.info setImage:infoImage];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    self.font = [UIFont fontWithName:@"Lato-Regular" size:18];
    self.textColor = [UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1];
    [self.store setFont:self.font];
    [self.store setTextColor:self.textColor];
    [self.name setFont:self.font];
    [self.name setTextColor:self.textColor];
    if([self.item valueForKey:@"image"] != nil){
        NSLog(@"Item set, using presets");
        [self presentProduct];
    }else{
        NSLog(@"Item not set, fetching item");
        [self fetchItem];
    }
    // Shop online nappi ja siihen hinta
    
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
