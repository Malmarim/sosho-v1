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
#import "SOSMineMessageView.h"

@interface SOSMessengerTalkViewController () {
    SOSFacebookFriend *fbFriend;
    NSMutableArray *messages;
    NSMutableArray *newMessages;
}
@property (nonatomic, strong) SOSFacebookFriendsDataController *friendsDataController;
@end

@implementation SOSMessengerTalkViewController
@synthesize messengerTableView;
@synthesize messageTextField;
@synthesize sendingMessageView;

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
    messages = [[NSMutableArray alloc] init];
    newMessages = [[NSMutableArray alloc] init];
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
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [messengerTableView addGestureRecognizer:gestureRecognizer];
    
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

#pragma mark - Text Field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	sendingMessageView.frame = CGRectMake(sendingMessageView.frame.origin.x, (sendingMessageView.frame.origin.y - 215.0), sendingMessageView.frame.size.width, sendingMessageView.frame.size.height);
    messengerTableView.frame = CGRectMake(messengerTableView.frame.origin.x, (messengerTableView.frame.origin.y), messengerTableView.frame.size.width, messengerTableView.frame.size.height - 215);
    
    
    if([messages count] > 0) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
        [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
    
    
	[UIView commitAnimations];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	sendingMessageView.frame = CGRectMake(sendingMessageView.frame.origin.x, (sendingMessageView.frame.origin.y + 215.0), sendingMessageView.frame.size.width, sendingMessageView.frame.size.height);
    messengerTableView.frame = CGRectMake(messengerTableView.frame.origin.x, (messengerTableView.frame.origin.y), messengerTableView.frame.size.width, messengerTableView.frame.size.height + 215);
    
    if([messages count] > 0) {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
        [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
    
	[UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[messageTextField resignFirstResponder];
}

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
    UILabel *youLabel;
    UITextView *messageText;
    UIImageView *imageView;
    
    if([[[[messages objectAtIndex:indexPath.row] valueForKey:@"recipent"] valueForKey:@"fbId" ]  isEqual: @"test2"]) {
        CellIdentifier = @"MineCell";
    } else {
        CellIdentifier = @"FriendCell";
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Check if a reusable cell object was dequeued
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
        [cell setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f
                                                 green:240.0f/255.0f
                                                  blue:245.0f/255.0f
                                                 alpha:1.0f]];
        
        if([CellIdentifier isEqualToString:@"MineCell"]) {
            CGRect myFrame = CGRectMake(10.0, 11.0, 42.0, 21.0);
            youLabel = [[UILabel alloc] initWithFrame:myFrame];
            youLabel.font = [UIFont systemFontOfSize:16.0];
            youLabel.textColor = [UIColor lightGrayColor];
            youLabel.textAlignment = NSTextAlignmentLeft;
            youLabel.text = @"YOU";
            [cell.contentView addSubview:youLabel];
        }
        
        CGRect bgFrame = CGRectMake(50, 0, 200, 30);
        SOSMineMessageView *messageBg = [[SOSMineMessageView alloc] initWithFrame:bgFrame];
        [cell.contentView addSubview:messageBg];
        
        
//        CGRect messageViewFrame = CGRectMake(50, 11, 200, 22);
//        imageView = [[UIImageView alloc] init];
//        [imageView setFrame:messageViewFrame];
//        if([CellIdentifier isEqualToString:@"MineCell"]) {
//            [imageView setBackgroundColor:[UIColor whiteColor]];
//        } else {
//            [imageView setBackgroundColor:[UIColor redColor]];
//        }
//        if([CellIdentifier isEqualToString:@"MineCell"]) {
//            [messageText setBackgroundColor:[UIColor clearColor]];
//        } else {
//            [messageText setBackgroundColor:[UIColor redColor]];
//        }
        
        CGRect messageFrame = CGRectMake(50, 0, 150, 30);
        messageText = [[UITextView alloc] initWithFrame:messageFrame];
        messageText.font = [UIFont systemFontOfSize:14.0];
        messageText.textColor = [UIColor blackColor];
        messageText.editable = NO;
        messageText.selectable = NO;
        messageText.scrollEnabled = NO;
        [messageText setBackgroundColor:[UIColor clearColor]];

        
        //    [messageText.layer setBorderWidth:2.0];
        //
        //    //The rounded corner part, where you specify your view's corner radius:
        messageText.layer.cornerRadius = 5;
        messageText.clipsToBounds = YES;
        messageText.textAlignment = NSTextAlignmentCenter;
        

        [cell.contentView addSubview:messageText];
    }
    
    // Populate the cell with the appropriate name based on the indexPath
        if([messages count] > 0) {
        messageText.text = [[messages objectAtIndex:indexPath.row] valueForKey:@"message"];
    }
   
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
#pragma mark Messenger related
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
            
            NSArray *tempmessages = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            
            messages = [NSMutableArray arrayWithArray:tempmessages];
//            [activityView stopAnimating];
//            activityView.hidden = YES;
            
            [messengerTableView reloadData];
            NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
            [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
            
            NSLog([NSString stringWithFormat:@"%@", [messages description]]);
        }else{
            
            //NSLog(@"Unable to fetch items: %@", error.localizedDescription);
            
            //[self showMessage:@"Unable to find new items, please try again later" withTitle:@"Error"];
            
        }

    }];
    
}

- (void) hideKeyboard {
    [messageTextField resignFirstResponder];
}

- (IBAction)sendMessageAction:(id)sender {
    
    if([messageTextField.text length] > 0) {
        NSString *url = @"http://soshotest.herokuapp.com/message";
        NSURL * fetchURL = [NSURL URLWithString:url];
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSString *params = [[NSString alloc] initWithFormat:@"sender=%@&recipent=%@&message=%@", @"test1", @"test2", messageTextField.text];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        NSOperationQueue * queue = [[NSOperationQueue alloc]init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
            if(!error){
                //NSLog(@"No Error");
                [self requestNewMessages];
            }
            else{
                //NSLog(@"Error");
            }
        }];

    }
    
    messageTextField.text = @"";
}

- (void)requestNewMessages {
    
    NSString *lastTime = [[messages lastObject] valueForKey:@"postedOn"];
    
    NSString *url = [NSString stringWithFormat:@"http://soshotest.herokuapp.com/newMessages/%@/%@/%@", @"test1", @"test2", lastTime];
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            newMessages = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            if([newMessages count ] > 0) {
                // New messages, do something
                [messages addObjectsFromArray:newMessages];
                [messengerTableView reloadData];
                NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
                [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
                }else{
                    //NSLog(@"Unable to fetch items: %@", error.localizedDescription);
                    //[self showMessage:@"Unable to find new items, please try again later" withTitle:@"Error"];
                }
        }}];
}
@end
