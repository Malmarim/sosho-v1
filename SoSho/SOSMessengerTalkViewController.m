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
#import "SoShoStyleKit.h"

@interface SOSMessengerTalkViewController () {
    SOSFacebookFriend *fbFriend;
    NSMutableArray *messages;
    NSMutableArray *newMessages;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIImageView *logo;
    __weak IBOutlet UIView *tabBar;
    __weak IBOutlet UIButton *homeButton;
    __weak IBOutlet UIButton *wishlistButton;
    __weak IBOutlet UIButton *messagesButton;
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
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Chat"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    self.friendId = @"test2";
    
    [backButton setImage:[SoShoStyleKit imageOfBTNGoBack] forState:UIControlStateNormal];
    [logo setImage:[SoShoStyleKit imageOfSoshoAppLogo]];
    
    [homeButton setImage:[SoShoStyleKit imageOfTabBarHomeInActive] forState:UIControlStateNormal];
    [wishlistButton setImage:[SoShoStyleKit imageOfTabBarWishlistInActive] forState:UIControlStateNormal];
    [messagesButton setImage:[SoShoStyleKit imageOfTabBarMessagesActive] forState:UIControlStateNormal];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0, 0.0, tabBar.frame.size.width, 1.0f);
    topBorder.backgroundColor = [UIColor colorWithRed: 1 green: 0.463 blue: 0.376 alpha: 1].CGColor;
    [tabBar.layer addSublayer:topBorder];
    
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
    static NSString* mineCellId = @"MineCellId";
    static NSString* friendCellId = @"FriendCellId";
    static NSString* mineImageCellId = @"MineImageCellId";
    static NSString* friendImageCellId = @"FriendImageCellId";
    UITableViewCell* cell = nil;
    
    UILabel *youLabel;
    UITextView *messageText;
    UIImageView *imageView;
    
    messageText.tag = 100;
    
    float numberOfRows = [[[messages objectAtIndex:indexPath.row] valueForKey:@"message"] length] / 30;
    numberOfRows++;
    
    if(([[messages objectAtIndex:indexPath.row] valueForKey:@"image"] != nil) && [[[messages objectAtIndex:indexPath.row] valueForKey:@"own"] boolValue]) {
        //Mine cell with image
        cell = [tableView dequeueReusableCellWithIdentifier:mineImageCellId];
        if( !cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mineImageCellId];
            
            [cell setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f
                                                     green:240.0f/255.0f
                                                      blue:245.0f/255.0f
                                                     alpha:1.0f]];
            
            CGRect myFrame = CGRectMake(10.0, 11.0, 42.0, 21.0);
            youLabel = [[UILabel alloc] initWithFrame:myFrame];
            youLabel.font = [UIFont systemFontOfSize:16.0];
            youLabel.textColor = [UIColor lightGrayColor];
            youLabel.textAlignment = NSTextAlignmentLeft;
            youLabel.text = @"YOU";
            [cell.contentView addSubview:youLabel];
            
            NSURL * imageURL = [NSURL URLWithString:[[messages objectAtIndex:indexPath.row] valueForKey:@"image"]];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage * image = [UIImage imageWithData:imageData];
            imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(60, 0, 220, 220);
            cell.frame = CGRectMake(0, 0, 360, 30*numberOfRows + imageView.frame.size.height);
            [cell.contentView addSubview:imageView];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            NSLog(@"Image url is present");
        }
        
        NSURL * imageURL = [NSURL URLWithString:[[messages objectAtIndex:indexPath.row] valueForKey:@"image"]];
        NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage * image = [UIImage imageWithData:imageData];
        imageView = [[UIImageView alloc] initWithImage:image];
        
    } else if([[[messages objectAtIndex:indexPath.row] valueForKey:@"own"] boolValue]) {
        //Mine cell
        cell = [tableView dequeueReusableCellWithIdentifier:mineCellId];
        if( !cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mineCellId];
            
            [cell setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f
                                                     green:240.0f/255.0f
                                                      blue:245.0f/255.0f
                                                     alpha:1.0f]];
            
            CGRect myFrame = CGRectMake(10.0, 11.0, 42.0, 21.0);
            youLabel = [[UILabel alloc] initWithFrame:myFrame];
            youLabel.font = [UIFont systemFontOfSize:16.0];
            youLabel.textColor = [UIColor lightGrayColor];
            youLabel.textAlignment = NSTextAlignmentLeft;
            youLabel.text = @"YOU";
            [cell.contentView addSubview:youLabel];
            
            
        }
        cell.frame = CGRectMake(0, 0, 360, 30*numberOfRows);
        
        CGRect messageFrame = CGRectMake(50, 0, 250, 30*numberOfRows);
        messageText = [[UITextView alloc] initWithFrame:messageFrame];
        messageText.font = [UIFont systemFontOfSize:14.0];
        messageText.textColor = [UIColor blackColor];
        messageText.editable = NO;
        messageText.selectable = NO;
        messageText.scrollEnabled = NO;
        [messageText setBackgroundColor:[UIColor clearColor]];
        
        messageText.textAlignment = NSTextAlignmentLeft;
        [messageText setBackgroundColor:[UIColor whiteColor]];
        
        messageText.layer.cornerRadius = 5;
        messageText.clipsToBounds = YES;
        messageText.textAlignment = NSTextAlignmentCenter;
        [messageText layoutIfNeeded];
        [messageText setText:[[messages objectAtIndex:indexPath.row] valueForKey:@"message"]];
        
        
        [cell.contentView addSubview:messageText];
        
    } else {
        //Friend cell
        cell = [tableView dequeueReusableCellWithIdentifier:friendCellId];
        if( !cell ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendCellId];
            [cell setBackgroundColor:[UIColor colorWithRed:245.0f/255.0f
                                                     green:240.0f/255.0f
                                                      blue:245.0f/255.0f
                                                     alpha:1.0f]];
            
            
        }
        cell.frame = CGRectMake(0, 0, 360, 30*numberOfRows);
        
        CGRect messageFrame = CGRectMake(50, 0, 250, 30*numberOfRows);
        messageText = [[UITextView alloc] initWithFrame:messageFrame];
        messageText.font = [UIFont systemFontOfSize:14.0];
        messageText.textColor = [UIColor blackColor];
        messageText.editable = NO;
        messageText.selectable = NO;
        messageText.scrollEnabled = NO;
        [messageText setBackgroundColor:[UIColor clearColor]];
        
        messageText.textAlignment = NSTextAlignmentRight;
        [messageText setBackgroundColor:[UIColor purpleColor]];
        
        messageText.layer.cornerRadius = 5;
        messageText.clipsToBounds = YES;
        messageText.textAlignment = NSTextAlignmentCenter;
        [messageText layoutIfNeeded];
        [messageText setText:[[messages objectAtIndex:indexPath.row] valueForKey:@"message"]];
        
        
        [cell.contentView addSubview:messageText];
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
    float numberOfRows = [[[messages objectAtIndex:indexPath.row] valueForKey:@"message"] length] / 30;
    numberOfRows++;
    
    if(([[messages objectAtIndex:indexPath.row] valueForKey:@"image"] != nil)) {
        return 260;
    }
    return (30*numberOfRows + 10);
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
    
    [messengerTableView reloadData];
    if([messages count] > 0){
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
        [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
}

-(void)fetchMessages{
    NSLog(@"Fetching messages");
    NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/messages/%@/%@", @"test1", @"test2"];
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
                NSLog(@"No messages");
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
        NSString *url = @"http://soshoapp.herokuapp.com/message";
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
        NSString *url = @"http://soshoapp.herokuapp.com/message";
        NSURL * fetchURL = [NSURL URLWithString:url];
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSString *params = [[NSString alloc] initWithFormat:@"sender=%@&recipent=%@&message=%@&image=%@", @"test1", @"test2", @"",  _itemUrl];
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
    
    NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/newMessages/%@/%@/%@", @"test1", @"test2", lastTime];
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
