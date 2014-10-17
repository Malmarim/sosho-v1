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

#import "UICollectionView+EmptyState.h"

@interface SOSFavoritesViewController ()

@property (strong, nonatomic) NSMutableArray *favorites;
@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

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
        //UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
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
            [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
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
         [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:self.clickedRow]];
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
    
    self.emptyView = [[UIView alloc] init];
    UILabel *placeholder = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
    placeholder.textAlignment = NSTextAlignmentCenter;
    [placeholder setTextColor:[UIColor colorWithRed:51/255.0 green:36/255.0 blue:45/255.0 alpha:1]];
    [placeholder setBackgroundColor:[UIColor clearColor]];
    [placeholder setFont:[UIFont fontWithName:@"Lato-Regular" size:15]];
    [placeholder setText:@"YOUR WISHLIST IS EMPTY"];
    [self.emptyView addSubview:placeholder];
    self.collection.emptyState_view = self.emptyView;
    self.collection.emptyState_shouldRespectSectionHeader = YES;
    
    self.collection.delegate = self;
    self.collection.dataSource = self;

    
    // Do any additional setup after loading the view.
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = .5; //seconds
    lpgr.delegate = self;
    [self.collectionView addGestureRecognizer:lpgr];
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
        NSArray *selected = [self.collectionView indexPathsForSelectedItems];
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


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reuseable = nil;
    
    if(kind == UICollectionElementKindSectionHeader){
        SOSCollectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
        UIImage *logo = [UIImage imageNamed:@"wishlist-button"];
        UIImageView *favorite = (UIImageView *)[header viewWithTag:3];
        [favorite setImage:logo];
        UIImage* itemImage = [UIImage imageNamed:@"small-logo.png"];
        UIButton *item = (UIButton *)[header viewWithTag:2];
        [item setImage:itemImage forState:UIControlStateNormal];
        UIImage* voteImage = [UIImage imageNamed:@"vote.png"];
        UIButton *votes = (UIButton *)[header viewWithTag:1];
        [votes setImage:voteImage forState:UIControlStateNormal];
        //header.controller = self;
        reuseable = header;
    }
    return reuseable;
}

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
    SOSFavoriteViewCell *myCell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"FavoriteCell"
                                    forIndexPath:indexPath];
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
