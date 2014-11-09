//
//  SOSMessengerTalkViewController.m
//  SoSho
//
//  Created by Artur Minasjan on 11/09/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSMessengerTalkViewController.h"
#import "SOSMessengerMineTableViewCell.h"
#import "SOSMessengerFriendTableViewCell.h"
#import "SOSMessengerImageTableViewCell.h"
#import "SOSFacebookFriendsDataController.h"
#import "SOSMineMessageView.h"
#import "SOSAppDelegate.h"
#import "SoShoStyleKit.h"


static NSString* mineCellId = @"MineCellId";
static NSString* friendCellId = @"FriendCellId";
static NSString* mineImageCellId = @"MineImageCellId";
static NSString* friendImageCellId = @"FriendImageCellId";

@interface SOSMessengerTalkViewController () {
    SOSFacebookFriend *fbFriend;
    NSMutableArray *messages;
    NSMutableArray *newMessages;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIView *tabBar;
    __weak IBOutlet UIButton *homeButton;
    __weak IBOutlet UIButton *wishlistButton;
    __weak IBOutlet UIButton *messagesButton;
}
@property (nonatomic, strong) SOSFacebookFriendsDataController *friendsDataController;
@property (strong, nonatomic) SOSAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) NSString *friendId;
@property (strong, nonatomic) NSString *fbId;
@property (weak, nonatomic) IBOutlet UILabel *name;

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


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.1
                     animations:^{
                    messengerTableView.frame = CGRectMake(messengerTableView.frame.origin.x, (messengerTableView.frame.origin.y), messengerTableView.frame.size.width, messengerTableView.frame.size.height - 202);
                         sendingMessageView.frame = CGRectMake(sendingMessageView.frame.origin.x, (sendingMessageView.frame.origin.y - 202.0), sendingMessageView.frame.size.width, sendingMessageView.frame.size.height);

    }];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.1
                     animations:^{
                         sendingMessageView.frame = CGRectMake(sendingMessageView.frame.origin.x, (sendingMessageView.frame.origin.y - 202.0), sendingMessageView.frame.size.width, sendingMessageView.frame.size.height);
                         messengerTableView.frame = CGRectMake(messengerTableView.frame.origin.x, (messengerTableView.frame.origin.y), messengerTableView.frame.size.width, messengerTableView.frame.size.height - 202);
                     }];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    //NSLog(@"Hidden");
    [UIView animateWithDuration:0.1
                     animations:^{
                         messengerTableView.frame = CGRectMake(messengerTableView.frame.origin.x, (messengerTableView.frame.origin.y), messengerTableView.frame.size.width, messengerTableView.frame.size.height + 202);
                         sendingMessageView.frame = CGRectMake(sendingMessageView.frame.origin.x, (sendingMessageView.frame.origin.y + 202.0), sendingMessageView.frame.size.width, sendingMessageView.frame.size.height);
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Chat"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    [self.messengerTableView registerClass:[SOSMessengerMineTableViewCell class] forCellReuseIdentifier:mineCellId];
    [self.messengerTableView registerClass:[SOSMessengerFriendTableViewCell class] forCellReuseIdentifier:friendCellId];
    [self.messengerTableView registerClass:[SOSMessengerImageTableViewCell class] forCellReuseIdentifier:mineImageCellId];
    [self.messengerTableView registerClass:[SOSMessengerImageTableViewCell class] forCellReuseIdentifier:friendImageCellId];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.fbId = [defaults objectForKey:@"fbId"];
    NSLog(@"own: %@", self.fbId);
    
    self.friendId = fbFriend.id;
    NSLog(@"friend: %@", self.friendId);
    
    [backButton setImage:[SoShoStyleKit imageOfBTNGoBack] forState:UIControlStateNormal];
    //[logo setImage:[SoShoStyleKit imageOfSoshoAppLogo]];
    
    [self.name setText:fbFriend.name];
    
    self.addPictureButton.hidden = _itemUrl ? NO : YES;
    
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

-(SOSFacebookFriend *)getFriend
{
    return fbFriend;
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
    
    if(([[messages objectAtIndex:indexPath.row] valueForKey:@"image"] != nil)) {
        //Mine cell with image
        SOSMessengerImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mineImageCellId];
        
        NSURL * imageURL = [NSURL URLWithString:[[messages objectAtIndex:indexPath.row] valueForKey:@"image"]];
        
        [cell.pictureImage setImage:nil];
        [self downloadImageWithURL:imageURL completionBlock:^(BOOL succeeded, NSData *data) {
            if (succeeded) {
                [cell.pictureImage setImage:[UIImage imageWithData:data]];
            }
        }];
        
        if([[[messages objectAtIndex:indexPath.row] valueForKey:@"own"] boolValue]) {
            cell.youLabel.hidden = NO;
        }
        else {
            cell.youLabel.hidden = YES;
        }
        
        return cell;
        
    } else if([[[messages objectAtIndex:indexPath.row] valueForKey:@"own"] boolValue]) {
        //Mine cell
        SOSMessengerMineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mineCellId];
        
        //CGRect messageFrame = CGRectMake(50, 0, 250, 30);
        
        cell.mineMessageLabel.text = [[messages objectAtIndex:indexPath.row] valueForKey:@"message"];
        //[cell.mineMessageLabel sizeToFit];
        
        return cell;
        
    } else {
        //Friend cell
        SOSMessengerFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:friendCellId];
        
        //CGRect messageFrame = CGRectMake(50, 0, 250, 30);
        
        cell.mineMessageLabel.text = [[messages objectAtIndex:indexPath.row] valueForKey:@"message"];
        //[cell.mineMessageLabel sizeToFit];
        
        return cell;
    }
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(([[messages objectAtIndex:indexPath.row] valueForKey:@"image"] != nil)) {
        return 260;
    }
    
    NSString *message = [[messages objectAtIndex:indexPath.row] valueForKey:@"message"];
    CGSize constraint = CGSizeMake(250, MAXFLOAT);
    //set your text attribute dictionary
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14.0] forKey:NSFontAttributeName];
    CGRect textsize = [message boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    
    return textsize.size.height+ 20;
    //float numberOfRows = [[[messages objectAtIndex:indexPath.row] valueForKey:@"message"] length] / 30;
    //numberOfRows++;
    //return (30*numberOfRows + 10);
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
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"friend == %@", self.friendId];
    [request setPredicate:pred];
    NSError *error;
    messages = [[self.context executeFetchRequest:request error:&error] mutableCopy];
    NSLog(@"%lu items loaded", (unsigned long)[messages count]);
    
    [messengerTableView reloadData];
    if(messages.count == 0) {
        [self fetchMessages];
    }
    else {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
        [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        [self requestNewMessages];
    }
    
    //[self requestNewMessages];
}

-(void)fetchMessages{
    NSLog(@"Fetching messages");
    NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/messages/%@/%@", self.fbId, self.friendId];
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
                NSLog(@"No new messages");
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
    NSLog(@"%lu messages saved", (unsigned long)[tempmessages count]);
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
        NSString *params = [[NSString alloc] initWithFormat:@"sender=%@&recipent=%@&message=%@", self.fbId, self.friendId, messageTextField.text];
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
    if (_itemUrl != nil) {
        NSString *url = @"http://soshoapp.herokuapp.com/message";
        NSURL * fetchURL = [NSURL URLWithString:url];
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSString *params = [[NSString alloc] initWithFormat:@"sender=%@&recipent=%@&message=%@&image=%@", self.fbId, self.friendId, @"",  _itemUrl];
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
    
    if(lastTime == nil)
        lastTime = [NSString stringWithFormat:@"%d", 0];
    
    NSString *url = [NSString stringWithFormat:@"http://soshoapp.herokuapp.com/newMessages/%@/%@/%@", self.fbId, self.friendId, lastTime];
    NSURL * fetchURL = [NSURL URLWithString:url];
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        if(!error){
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            newMessages = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            if([newMessages count ] > 0) {
                // New messages, do something
                NSLog(@"Message count: %lu", (unsigned long)[newMessages count]);
                NSLog(@"Message: %@", [newMessages objectAtIndex:0][@"message"]);
                //[messages addObjectsFromArray:newMessages];
                [self saveMessages:newMessages];
                [messengerTableView reloadData];
                NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messages count]-1 inSection:0];
                [messengerTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
            }else{
                NSLog(@"No new messages found");
                //[self showMessage:@"Unable to find new items, please try again later" withTitle:@"Error"];
            }
        }
        else{
            NSLog(@"Unable to fetch items: %@", error.localizedDescription);
        }
    }];
}
@end
