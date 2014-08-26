//
//  SOSTempViewController.m
//  SoSho
//
//  Created by Artur Minasjan on 24/08/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSTempViewController.h"
#import "FacebookSDK/FacebookSDK.h"
#import "SOSFacebookFriendsDataController.h"
#import "SOSFacebookFriendTableViewCell.h"
#import "SOSFacebookFriend.h"

@interface SOSTempViewController ()
@property (nonatomic, strong) SOSFacebookFriendsDataController *friendsDataController;
@end

@implementation SOSTempViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friendsDataController = [[SOSFacebookFriendsDataController alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
//    [FBRequestConnection startForMyFriendsWithCompletionHandler:
//     ^(FBRequestConnection *connection, id<FBGraphUser> friends, NSError *error)
//     {
//         if(!error){
//             NSLog(@"results = %@", friends);
//             
//         }
//         self.contacts = (NSArray*)[friends objectForKey:@"data"];
//     }
//     ];
    
    [FBRequestConnection startWithGraphPath:@"/me/taggable_friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              if(error){
                                  NSLog(@"results = %@", result);
                                  
                              }
                          }];
}

- (void)closeTableView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.friendsDataController friendsCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SOSFacebookFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookFriendCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.nameLabel.text = [[[self.friendsDataController friendAtIndex:indexPath.row] name] uppercaseString];
    
    return cell;
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

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
