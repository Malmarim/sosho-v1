//
//  SOSFriendListViewController.m
//  SoSho
//
//  Created by Mikko Malmari on 5.11.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSFriendListViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SOSFriendListViewCell.h"
#import "SoShoStyleKit.h"

#import "SOSFacebookFriend.h"
#import "SOSMessengerTalkViewController.h"

@interface SOSFriendListViewController ()

@property (strong, nonatomic) NSArray *friendList;
@property (strong, nonatomic) NSMutableArray *filtered;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UIView *tabBar;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *wishlistButton;
@property (weak, nonatomic) IBOutlet UIButton *messagesButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation SOSFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.table.delegate = self;
    self.table.dataSource = self;

    [self.homeButton setImage:[SoShoStyleKit imageOfTabBarHomeInActive] forState:UIControlStateNormal];
    [self.wishlistButton setImage:[SoShoStyleKit imageOfTabBarWishlistInActive] forState:UIControlStateNormal];
    [self.messagesButton setImage:[SoShoStyleKit imageOfTabBarMessagesActive] forState:UIControlStateNormal];
    
    [self.logo setImage:[SoShoStyleKit imageOfSoshoAppLogo]];
    // Add a topBorder.
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, self.tabBar.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithRed: 1 green: 0.463 blue: 0.376 alpha: 1].CGColor;
    [self.tabBar.layer addSublayer:topBorder];
    
    
    [self loadFriends];
    // Do any additional setup after loading the view.
}

- (void)loadFriends
{
    [FBRequestConnection startForMyFriendsWithCompletionHandler:
     ^(FBRequestConnection *connection, id<FBGraphUser> friends, NSError *error){
         if(!error){
             self.friendList = [friends objectForKey:@"data"];
             self.filtered = [NSMutableArray arrayWithCapacity:[self.friendList count]];
             [self.table reloadData];
         }
     }];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope
{
    [self.filtered removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.filtered = [NSMutableArray arrayWithArray:[self.friendList filteredArrayUsingPredicate:resultPredicate]];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filtered count];
    }else{
        return [self.friendList count];
    }
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     
     SOSFriendListViewCell *myCell = [self.table dequeueReusableCellWithIdentifier:@"FriendCell"];
     
     if(myCell == nil){
         myCell = [[SOSFriendListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCell"];
     }
     
     long row = [indexPath row];
     NSDictionary *item;
     if(tableView == self.searchDisplayController.searchResultsTableView){
         item = [self.filtered objectAtIndex:row];
     }else{
         item = [self.friendList objectAtIndex:row];
     }
     
     myCell.name.text = [item valueForKey:@"name"];
     
     NSString *imageUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [item valueForKey:@"id"]];
     NSURL *url = [NSURL URLWithString:imageUrl];
     [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, NSData *data) {
         if (succeeded) {
            [myCell.picture setImage:[[UIImage alloc] initWithData:data]];
             //[self reloadImages:[indexPath row]];
         }
     }];
     CALayer *imageLayer = myCell.picture.layer;
     [imageLayer setCornerRadius:15];
     [imageLayer setBorderWidth:0];
     [imageLayer setMasksToBounds:YES];

     return myCell;
 }
 
- (IBAction)unwindToFriendList:(UIStoryboardSegue *)unwindSegue
{
    
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     // Make sure segue is forwards not backwards (Favorite view)
     if([segue.destinationViewController isKindOfClass:[SOSMessengerTalkViewController class]]){
         // Assume self.view is the table view
         NSIndexPath *path = [self.table indexPathForSelectedRow];
         NSLog(@"Clicked on %ld", (long)[path row]);
         NSDictionary *item;
         if(self.searchDisplayController.active){
             path = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
             item = [self.filtered objectAtIndex:[path row]];
         }else{
             item = [self.friendList objectAtIndex:[path row]];
         }
         
         SOSFacebookFriend *friend = [[SOSFacebookFriend alloc] init];
         friend.id = [item objectForKey:@"id"];
         friend.name = [item objectForKey:@"name"];
         [segue.destinationViewController setFriend:friend];
    
     }
     

 }

@end
