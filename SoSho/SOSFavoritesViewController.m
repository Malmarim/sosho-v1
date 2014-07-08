//
//  SOSFavoriteViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 5.6.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSFavoritesViewController.h"
#import "SOSAppDelegate.h"
#import "SOSFavoriteViewCell.h"
#import "SOSFavoriteViewController.h"

@interface SOSFavoritesViewController ()

@property (strong, nonatomic) NSArray *favorites;
@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (nonatomic) long clickedRow;

@end

@implementation SOSFavoritesViewController

- (IBAction)swipeLeft:(id)sender {
}

// Load favorites saved to file
- (void) loadItems
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Favorites" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSError *error;
    self.favorites = [self.context executeFetchRequest:request error:&error];
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
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
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
    SOSFavoriteViewController *destination = (SOSFavoriteViewController *) segue.destinationViewController;
    NSArray *selected = [self.collectionView indexPathsForSelectedItems];
    destination.favorite = [self.favorites objectAtIndex:[selected[0] row]];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
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
