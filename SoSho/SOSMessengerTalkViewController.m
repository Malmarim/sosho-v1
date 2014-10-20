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
#import "SOSAppDelegate.h"

@interface SOSMessengerTalkViewController () {
    SOSFacebookFriend *fbFriend;
    NSMutableArray *messages;
    NSMutableArray *newMessages;
}
@property (nonatomic, strong) SOSFacebookFriendsDataController *friendsDataController;
@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) NSString *friendId;

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
    
    self.friendId = @"test2";
    
   // messages = [[NSMutableArray alloc] init];
    
    newMessages = [[NSMutableArray alloc] init];
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
   
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
    //[self fetchMessages];
    [self loadMessages];
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

- (void)setItemImage:(UIImageView *)image {
    _itemImage = image;
}

-(void)setItemUrl:(NSString *)itemUrl {
    _itemUrl = itemUrl;
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
    
    messageText.tag = 100;
    
    if([[[messages objectAtIndex:indexPath.row] valueForKey:@"own"] boolValue]) {
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
        
        float numberOfRows = [[[messages objectAtIndex:indexPath.row] valueForKey:@"message"] length] / 30;
        numberOfRows++;
        
        CGRect messageFrame = CGRectMake(50, 0, 250, 30*numberOfRows);
        messageText = [[UITextView alloc] initWithFrame:messageFrame];
        messageText.font = [UIFont systemFontOfSize:14.0];
        messageText.textColor = [UIColor blackColor];
        messageText.editable = NO;
        messageText.selectable = NO;
        messageText.scrollEnabled = NO;
        [messageText setBackgroundColor:[UIColor clearColor]];
        
        if([CellIdentifier isEqualToString:@"MineCell"]) {
            messageText.textAlignment = NSTextAlignmentLeft;
            [messageText setBackgroundColor:[UIColor whiteColor]];
        } else {
            messageText.textAlignment = NSTextAlignmentRight;
            [messageText setBackgroundColor:[UIColor purpleColor]];
        }
        
        //    [messageText.layer setBorderWidth:2.0];
        //
        //    //The rounded corner part, where you specify your view's corner radius:
        messageText.layer.cornerRadius = 5;
        messageText.clipsToBounds = YES;
        messageText.textAlignment = NSTextAlignmentCenter;
//        [messageText sizeToFit];
        [messageText layoutIfNeeded];
        [messageText setText:[[messages objectAtIndex:indexPath.row] valueForKey:@"message"]];
        [cell.contentView addSubview:messageText];
    }else{
        //NSLog(@"Subviews");
        // TODO remove textview, change text and readd
        [(UITextView *)[cell.contentView viewWithTag:100] setText:[[messages objectAtIndex:indexPath.row] valueForKey:@"message"]];
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


// Load messages saved to file
- (void) loadMessages
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:self.context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    // Friends fbId needs to be passed
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"friend == %@", @"test2"];
    [request setPredicate:pred];
    NSError *error;
    messages = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    NSLog(@"%d items loaded", [messages count]);
    
    if(messages.count == 0)
        [self fetchMessages];
    
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
    [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];

}

-(void)fetchMessages{
    NSLog(@"Fetching messages");
    NSString *url = [NSString stringWithFormat:@"http://soshotest.herokuapp.com/messages/%@/%@", @"test1", @"test2"];
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            NSArray *tempmessages = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            // This will save the messages to core data
            if([tempmessages count] > 0)
                [self saveMessages:tempmessages];
            else{
                // No messages, need to do something
            }
            /*
            messages = [NSMutableArray arrayWithArray:tempmessages];
            [messengerTableView reloadData];
            NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
            [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
            NSLog(@"%d messages downloaded", [messages count]);
            //NSLog([NSString stringWithFormat:@"%@", [messages description]]);
            */
        }else{
            NSLog(@"Unable to fetch items: %@", error.localizedDescription);
        }
    }];
}

- (void) saveMessages: (NSArray *)tempmessages
{
    NSManagedObject *newMessage;
    NSError *error;
    for(int i=0; i<[tempmessages count]; i++) {
        newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:self.context];
        
        BOOL own = [[tempmessages objectAtIndex:i][@"recipent"][@"fbId"] isEqualToString: self.friendId] ? YES : NO;
        
        if(own){
            // Message is ours, set friend from recipent
            [newMessage setValue: [tempmessages objectAtIndex: i][@"recipent"][@"fbId"] forKey:@"friend"];
        }else{
            // Message is theirs, set friend from sender and own status to false
            [newMessage setValue: [tempmessages objectAtIndex: i][@"sender"][@"fbId"] forKey:@"friend"];
        }
        [newMessage setValue: [NSNumber numberWithBool:own] forKey:@"own"];
        
        // check if image is not or not, if not set image to message
        if(![[tempmessages objectAtIndex:i][@"image"] isEqual:[NSNull null]])
            [newMessage setValue: [tempmessages objectAtIndex: i][@"image"] forKey:@"image"];
        
        [newMessage setValue: [tempmessages objectAtIndex:i][@"message"] forKey:@"message"];
        [newMessage setValue: [tempmessages objectAtIndex:i][@"postedOn"] forKey:@"timestamp"];
        //[newMessage setValue: [NSDate dateWithTimeIntervalSince1970:[[tempmessages objectAtIndex: i][@"postedOn"] doubleValue]] forKey:@"timestamp"];
        
        [self.context save:&error];
        /*
        if(i == [tempmessages count]-1)
        {
            // You can use this to save the timestamp of last message to user defaults for faster access, needs the logic to do it
            self.lastFetched = [[self.loadedItems objectAtIndex: i][@"id"] intValue];
            [self saveLastFetched];
        }
        */
    }
    NSLog(@"%d messages saved", [tempmessages count]);
    [self loadMessages];
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

- (void)sendImage {
    if (_itemImage != nil) {
        NSString *url = @"http://soshotest.herokuapp.com/message";
        NSURL * fetchURL = [NSURL URLWithString:url];
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSString *params = [[NSString alloc] initWithFormat:@"sender=%@&recipent=%@&image=%@", @"test1", @"test2", _itemUrl];
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
    } else {
        NSLog(@"item image cannot be sent");
    }
}

- (IBAction)addPictureAction:(id)sender {
    [self sendImage];
}

- (void)requestNewMessages {
    
    NSString *lastTime = [[messages lastObject] valueForKey:@"timestamp"];
    NSLog(@"Last time %@", lastTime);
    
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
                NSLog(@"Message count: %d", [newMessages count]);
                NSLog(@"Message: %@", [newMessages objectAtIndex:0][@"message"]);
                //[messages addObjectsFromArray:newMessages];
                [self saveMessages:newMessages];
                [messengerTableView reloadData];
                NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
                [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
            }else{
                NSLog(@"Unable to fetch items: %@", error.localizedDescription);
                //[self showMessage:@"Unable to find new items, please try again later" withTitle:@"Error"];
            }
        }
        else{
            NSLog(@"Unable to fetch items: %@", error.localizedDescription);
        }
    }];
}
@end
