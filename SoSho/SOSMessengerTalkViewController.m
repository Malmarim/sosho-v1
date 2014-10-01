//
//  SOSMessengerTalkViewController.m
//  SoSho
//
//  Created by Artur Minasjan on 11/09/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSMessengerTalkViewController.h"
#import "SOSMessengerMineTableViewCell.h"
#import "SOSFacebookFriendsDataController.h"

@interface SOSMessengerTalkViewController () {
    SOSFacebookFriend *fbFriend;
    NSArray *messages;
}
@property (nonatomic, strong) SOSFacebookFriendsDataController *friendsDataController;
@end

@implementation SOSMessengerTalkViewController
@synthesize messengerTableView;

- (id)initWithFriend:(SOSFacebookFriend *)friend {
    self = [super init];
    if(self) {
        fbFriend = friend;
    }
    return self;
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
    [self fetchMessages];
    // Do any additional setup after loading the view.
    self.friendsDataController = [[SOSFacebookFriendsDataController alloc] init];
    
    [messengerTableView setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f
                                                          green:240.0f/255.0f
                                                           blue:245.0f/255.0f
                                                          alpha:1.0f]];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f
                                                  green:240.0f/255.0f
                                                   blue:245.0f/255.0f
                                                  alpha:1.0f]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(13.0, 30.0, 30.0, 30.0);
    [button setImage: [[UIImage imageNamed: @"wishlist-button.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal] forState: UIControlStateNormal];
    [self.view addSubview:button];
    
    UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 250, 50)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor=[UIColor grayColor];
    label.numberOfLines=0;
    label.text = @"ASK A FRIEND";
    [self.view addSubview:label];
    
//    messengerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, 360, 390)];
//    messengerTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    messengerTableView.delegate = self;
//    messengerTableView.dataSource = self;
//    [messengerTableView setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f
//                                                         green:240.0f/255.0f
//                                                          blue:245.0f/255.0f
//                                                         alpha:1.0f]];
//    
//    [self.view addSubview:messengerTableView];
    
}

- (void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    messengerTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonPressed:(id)sender {
   [self.navigationController popViewControllerAnimated:YES];
}

- (void)setFriend:(SOSFacebookFriend *)friend {
    fbFriend = friend;
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [[fbFriend messagesHistory] count];
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    
    if([[[[messages objectAtIndex:indexPath.row] valueForKey:@"recipent"] valueForKey:@"fbId" ]  isEqual: @"test1"]) {
        CellIdentifier = @"MineCell";
    } else {
        CellIdentifier = @"FriendCell";
    }
    
    
    SOSMessengerMineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Check if a reusable cell object was dequeued
    if (cell == nil) {
        cell = [[SOSMessengerMineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Populate the cell with the appropriate name based on the indexPath
    if([messages count] > 0) {
        cell.mineMessageLabel.text = [[messages objectAtIndex:indexPath.row] valueForKey:@"message"];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

-(void)fetchMessages{
    
//    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    
//    activityView.center=self.messengerTableView.center;
//    [activityView setColor:[UIColor blackColor]];
//    [activityView startAnimating];
//    
//    [self.messengerTableView addSubview:activityView];
    
    NSString *url = [NSString stringWithFormat:@"http://soshotest.herokuapp.com/messages/%@/%@", @"test1", @"test2"];
    
    NSURL * fetchURL = [NSURL URLWithString:url];
    
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        
        if(!error){
            
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            
            messages = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            
//            [activityView stopAnimating];
//            activityView.hidden = YES;
            
            [messengerTableView reloadData];
            NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
            [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
            
//            NSLog([NSString stringWithFormat:@"%@", [messages description]]);
        }else{
            
            //NSLog(@"Unable to fetch items: %@", error.localizedDescription);
            
            //[self showMessage:@"Unable to find new items, please try again later" withTitle:@"Error"];
            
        }

    }];
    
}



@end
