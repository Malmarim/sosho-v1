//
//  SOSFavoriteViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 5.6.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSFavoritesViewController.h"
#import "SOSAppDelegate.h"
#import "SOSCollectionHeader.h"
#import "SOSFavoriteViewCell.h"
#import "SOSFavoriteViewController.h"
#import "SOSLabel.h"
#import "SoShoStyleKit.h"
#import "SOSCollectionFooter.h"
#import "UICollectionView+EmptyState.h"

@interface SOSFavoritesViewController ()

@property (strong, nonatomic) NSMutableArray *favorites;
@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UIView *tabbar;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UIButton *messagesButton;

@property (weak, nonatomic) IBOutlet UICollectionView *collection;
@property (strong, nonatomic) UIView *emptyView;
@property (nonatomic) NSIndexPath *clickedRow;

@end

@implementation SOSFavoritesViewController

- (IBAction)bar:(id)sender {
    [self performSegueWithIdentifier:@"favoritestovotes" sender:self];
    [self sendEvent:@"Votelist"];
}

- (void)sendEvent:(NSString *) label
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:label          // Event label
                                                           value:nil] build]];    // Event value
}

// Load favorites saved to file
- (void) loadItems
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Favorites" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    self.favorites = [[self.context executeFetchRequest:request error:&error] mutableCopy];
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

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.collection];
    
    NSIndexPath *indexPath = [self.collection indexPathForItemAtPoint:p];
    if (indexPath == nil){
        //NSLog(@"couldn't find index path");
    } else {
        //NSLog(@"Found cell");
        // get the cell at indexPath (the one you long pressed)
        //UICollectionViewCell* cell = [self.collection cellForItemAtIndexPath:indexPath];
        //long row = [indexPath row];
        //NSDictionary *item = [self.favorites objectAtIndex:row];
        // do stuff with the cell
        self.clickedRow = indexPath;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete this favorite?" message:@"If deleted, it will be lost for good" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [alert show];
        /*
        long row = [indexPath row];
        [self.context deleteObject:[self.favorites objectAtIndex:row]];
        NSError *error = nil;
        if(![self.context save:&error]){
            //NSLog(@"Delete failed");
        }else{
            [self.favorites removeObjectAtIndex:row];
            [self.collection deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            //NSLog(@"Delete succeeded");
        }
        */
        //[self.collection reloadData];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        NSLog(@"Cancel");
        //cancel clicked ...do your action
    }else{
        NSLog(@"Delete");
        [self sendEvent:@"Favorite deleted"];
         long row = [self.clickedRow row];
         [self.context deleteObject:[self.favorites objectAtIndex:row]];
         NSError *error = nil;
         if(![self.context save:&error]){
         //NSLog(@"Delete failed");
         }else{
         [self.favorites removeObjectAtIndex:row];
         [self.collection deleteItemsAtIndexPaths:[NSArray arrayWithObject:self.clickedRow]];
         //NSLog(@"Delete succeeded");
         }
        //reset clicked
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Favorites"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    self.collection.delegate = self;
    self.collection.dataSource = self;
    
    self.emptyView = [[UIView alloc] init];
    UILabel *ph1 = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, 260, 40)];
    ph1.textAlignment = NSTextAlignmentCenter;
    [ph1 setTextColor:[UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1]];
    [ph1 setBackgroundColor:[UIColor clearColor]];
    [ph1 setFont:[UIFont fontWithName:@"Lato-Regular" size:15]];
    [ph1 setText:@"There are currently no items in your wishlist."];
    [ph1 setNumberOfLines:0];
    [ph1 sizeToFit];
    [self.emptyView addSubview:ph1];
    
    UILabel *ph2 = [[UILabel alloc] initWithFrame:CGRectMake(40, 100, 260, 40)];
    ph2.textAlignment = NSTextAlignmentCenter;
    [ph2 setTextColor:[UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1]];
    [ph2 setBackgroundColor:[UIColor clearColor]];
    [ph2 setFont:[UIFont fontWithName:@"Lato-Regular" size:15]];
    [ph2 setText:@"To add your favorite pairs press the heart-button"];
    [ph2 setNumberOfLines:0];
    [ph2 sizeToFit];
    [self.emptyView addSubview:ph2];
    
    UILabel *ph3 = [[UILabel alloc] initWithFrame:CGRectMake(140, 130, 40, 40)];
    ph3.textAlignment = NSTextAlignmentCenter;
    [ph3 setTextColor:[UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1]];
    [ph3 setBackgroundColor:[UIColor clearColor]];
    [ph3 setFont:[UIFont fontWithName:@"Lato-Regular" size:15]];
    [ph3 setText:@"or"];
    [self.emptyView addSubview:ph3];
    
    UILabel *ph4 = [[UILabel alloc] initWithFrame:CGRectMake(40, 170, 260, 80)];
    ph4.textAlignment = NSTextAlignmentCenter;
    [ph4 setTextColor:[UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1]];
    [ph4 setBackgroundColor:[UIColor clearColor]];
    [ph4 setFont:[UIFont fontWithName:@"Lato-Regular" size:15]];
    [ph4 setText:@"swipe the image of a pair to the right"];
    [ph4 setNumberOfLines:0];
    [ph4 sizeToFit];
    [self.emptyView addSubview:ph4];
    
    self.collection.emptyState_view = self.emptyView;
    self.collection.emptyState_shouldRespectSectionHeader = YES;
    
    self.collection.delegate = self;
    self.collection.dataSource = self;
    
    [self.homeButton setImage:[SoShoStyleKit imageOfTabBarHomeInActive] forState:UIControlStateNormal];
    [self.wishlistButton setImage:[SoShoStyleKit imageOfTabBarWishlistActive] forState:UIControlStateNormal];
    [self.messagesButton setImage:[SoShoStyleKit imageOfTabBarMessagesInActive] forState:UIControlStateNormal];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, self.tabbar.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithRed: 1 green: 0.463 blue: 0.376 alpha: 1].CGColor;
    [self.tabbar.layer addSublayer:topBorder];

    [self.logo setImage:[SoShoStyleKit imageOfSoshoAppLogo]];
    
    // Do any additional setup after loading the view.
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    // attach long press gesture to collection View
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    [self.collection addGestureRecognizer:lpgr];
    [self loadItems];
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
    if([segue.identifier isEqualToString:@"favoritestofavorite"])
    {
        [self sendEvent:@"Favorite"];
        SOSFavoriteViewController *destination = (SOSFavoriteViewController *) segue.destinationViewController;
        NSArray *selected = [self.collection indexPathsForSelectedItems];
        destination.favorite = [self.favorites objectAtIndex:[selected[0] row]];
    }
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

/*
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reuseable = nil;
    
    if(kind == UICollectionElementKindSectionHeader){
        SOSCollectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
        UIImageView *favorite = (UIImageView *)[header viewWithTag:3];
        [favorite setImage:[SoShoStyleKit imageOfSoshoAppLogo]];
        //header.controller = self;
        reuseable = header;
    }else if(kind == UICollectionElementKindSectionFooter){
        SOSCollectionFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        [footer.homeButton setImage:[SoShoStyleKit imageOfTabBarHomeInActive] forState:UIControlStateNormal];
        [footer.wishlistButton setImage:[SoShoStyleKit imageOfTabBarWishlistActive] forState:UIControlStateNormal];
        [footer.messagesButton setImage:[SoShoStyleKit imageOfTabBarMessagesInActive] forState:UIControlStateNormal];
        
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0, 0.0, footer.frame.size.width, 1.0f);
        topBorder.backgroundColor = [UIColor colorWithRed: 1 green: 0.463 blue: 0.376 alpha: 1].CGColor;
        [footer.layer addSublayer:topBorder];
        
        reuseable = footer;
    }
    return reuseable;
}
*/
 
- (IBAction)unwindToFavorites:(UIStoryboardSegue *)unwindSegue
{
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return [self.favorites count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SOSFavoriteViewCell *myCell = [self.collection
                                    dequeueReusableCellWithReuseIdentifier:@"FavoriteCell"
                                    forIndexPath:indexPath];
    
    myCell.background.layer.borderColor = [UIColor colorWithRed:245/255 green:240/255 blue:245/255 alpha:0.5].CGColor;
    
    myCell.background.layer.borderWidth = 0.5;
    myCell.background.layer.cornerRadius = 4.0;
    myCell.background.layer.masksToBounds = YES;
    
    long row = [indexPath row];
    NSDictionary *item = [self.favorites objectAtIndex:row];
    NSURL *url = [NSURL URLWithString:[item valueForKey: @"image"]];
    [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, NSData *data) {
        if (succeeded) {
            [myCell.image setImage:[[UIImage alloc] initWithData:data]];
        }
    }];
    return myCell;
}

/*
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    long row = [indexPath row];
    self.clickedRow = row;
}
*/
@end
