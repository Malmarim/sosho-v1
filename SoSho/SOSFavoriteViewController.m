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
@property (weak, nonatomic) IBOutlet UIButton *visit;

@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (nonatomic) int itemId;

@end

@implementation SOSFavoriteViewController

- (IBAction)buttonTouched:(id)sender {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlString]];
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

- (void)loadItem
{
    if(self.favorite != nil){
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
    [self loadItem];
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
