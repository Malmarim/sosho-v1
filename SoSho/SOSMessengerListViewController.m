//
//  SOSTempViewController.m
//  SoSho
//
//  Created by Artur Minasjan on 24/08/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSMessengerListViewController.h"
#import "SOSMessengerTalkViewController.h"
#import "FacebookSDK/FacebookSDK.h"
#import "SOSFacebookFriendsDataController.h"
#import "SOSFacebookFriendTableViewCell.h"
#import "SOSFacebookFriend.h"
#import "SoShoStyleKit.h"

@interface SOSMessengerListViewController () {
    NSArray *searchResults;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIImageView *logo;
    __weak IBOutlet UIView *tabbar;
    __weak IBOutlet UIButton *homeButton;
    __weak IBOutlet UIButton *wishlistButton;
    __weak IBOutlet UIButton *messagesButton;
}
@property (nonatomic, strong) SOSFacebookFriendsDataController *friendsDataController;
@end

@implementation SOSMessengerListViewController
@synthesize friendsTableView;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


- (IBAction)unwindToMessenger:(UIStoryboardSegue *)unwindSegue
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Friendlist"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [backButton setImage:[SoShoStyleKit imageOfBTNGoBack] forState:UIControlStateNormal];
    [logo setImage:[SoShoStyleKit imageOfSoshoAppLogo]];
    
    [homeButton setImage:[SoShoStyleKit imageOfTabBarHomeInActive] forState:UIControlStateNormal];
    [wishlistButton setImage:[SoShoStyleKit imageOfTabBarWishlistInActive] forState:UIControlStateNormal];
    [messagesButton setImage:[SoShoStyleKit imageOfTabBarMessagesActive] forState:UIControlStateNormal];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, tabbar.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithRed: 1 green: 0.463 blue: 0.376 alpha: 1].CGColor;
    [tabbar.layer addSublayer:topBorder];
    
    self.friendsDataController = [[SOSFacebookFriendsDataController alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:
     ^(FBRequestConnection *connection, id<FBGraphUser> friends, NSError *error)
     {
         if(!error){
             //NSLog(@"results = %@", friends);
         }
     }
     ];
 
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    friendsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if([self.friendsDataController friendsCount] == 0) {
        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        activityView.center=self.view.center;
        [activityView setColor:[UIColor blackColor]];
        [activityView startAnimating];
        
        [self.view addSubview:activityView];
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:
         ^(FBRequestConnection *connection, id<FBGraphUser> friends, NSError *error)
         {
             if(!error){
                 //NSLog(@"results = %@", friends);
                 NSArray* listOfFriends = [friends objectForKey:@"data"];
                 
                 for (NSDictionary<FBGraphUser>* friend in listOfFriends) {
                     NSString *imageUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", friend.objectID];
                     [self.friendsDataController addFriend:friend.name withImage:imageUrl andId:friend.objectID];
                 }                 
                 [activityView stopAnimating];
                 [self.friendsTableView reloadData];
             }
         }
         ];
    }
    
    NSIndexPath *selected = [friendsTableView indexPathForSelectedRow];
    if ( selected ) [friendsTableView deselectRowAtIndexPath:selected animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    searchResults = [self.friendsDataController.allFriendsList filteredArrayUsingPredicate:resultPredicate];
}

#pragma mark - Search Display delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [self.friendsDataController friendsCount];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SOSFacebookFriendTableViewCell *cell = [friendsTableView dequeueReusableCellWithIdentifier:@"FacebookFriendCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SOSFacebookFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FacebookFriendCell"];
    }
    
    // Configure the cell...
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.nameLabel.text = [[[searchResults objectAtIndex:indexPath.row] name] uppercaseString];
        UIImage * img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[searchResults objectAtIndex:indexPath.row] imageUrl]]]];
        cell.pictureImage.image = img;
        
        CALayer *imageLayer = cell.pictureImage.layer;
        [imageLayer setCornerRadius:15];
        [imageLayer setBorderWidth:0];
        [imageLayer setMasksToBounds:YES];
        
    } else {
        cell.nameLabel.text = [[[self.friendsDataController friendAtIndex:indexPath.row] name] uppercaseString];
        
        UIImage * img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[self.friendsDataController friendAtIndex:indexPath.row] imageUrl]]]];
        cell.pictureImage.image = img;
        
        CALayer *imageLayer = cell.pictureImage.layer;
        [imageLayer setCornerRadius:15];
        [imageLayer setBorderWidth:0];
        [imageLayer setMasksToBounds:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    SOSMessengerTalkViewController *talkView = [[SOSMessengerTalkViewController alloc] initWithFriend:[self.friendsDataController friendAtIndex:indexPath.row]];
//    
//    [[self navigationController] pushViewController:talkView animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure segue is forwards not backwards (Favorite view)
    if([segue.destinationViewController isKindOfClass:[SOSMessengerTalkViewController class]]){
        // Assume self.view is the table view
        NSIndexPath *path = [friendsTableView indexPathForSelectedRow];
        SOSFacebookFriend *friend = [self.friendsDataController friendAtIndex:path.row];
        [segue.destinationViewController setFriend:friend];
        
        if(self.image != nil){
            NSLog(@"Image is not nil");
            [segue.destinationViewController setItemImage:self.image];
            [segue.destinationViewController setItemUrl:_imageUrl];
        }else
            NSLog(@"Image is nil");
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
