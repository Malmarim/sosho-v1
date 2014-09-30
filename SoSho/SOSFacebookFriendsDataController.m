//
//  SOSFacebookFriendsDataController.m
//  SoSho
//
//  Created by Artur Minasjan on 25/08/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSFacebookFriendsDataController.h"
#import "SOSFacebookFriend.h"
#import "FacebookSDK/FacebookSDK.h"
@interface SOSFacebookFriendsDataController ()

@property (nonatomic, readonly) NSMutableArray *friendsList;
@property (nonatomic, readonly) NSMutableArray *conversationMessages;

@end

@implementation SOSFacebookFriendsDataController

- (id)init {
    self = [super init];
    
    if(self) {
        _friendsList = [[NSMutableArray alloc] init];
        _conversationMessages = [[NSMutableArray alloc] init];
        return self;
    }
    
    return nil;
}

- (NSUInteger)friendsCount {
    return [self.friendsList count];
}

- (SOSFacebookFriend *)friendAtIndex:(NSUInteger)index {
    return [self.friendsList objectAtIndex:index];
}

- (NSArray *)allFriendsList {
    return self.friendsList;
}

- (void)addFriend:(NSString *)name withImage:(NSString *)image andId:(NSString *)id {
    SOSFacebookFriend *friend = [[SOSFacebookFriend alloc] initWithName:name ImageUrl:image andId:id];
    [self.friendsList addObject:friend];
}

-(void)fetchMessages{
    
    NSString *url = [NSString stringWithFormat:@"http://soshotest.herokuapp.com/messages/%@/%@", @"test1", @"test2"];
    
    NSURL * fetchURL = [NSURL URLWithString:url];
    
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:fetchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data,   NSError * error) {
        
        if(!error){
            
            NSData * jsonData = [NSData dataWithContentsOfURL:fetchURL];
            
            _conversationMessages = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

        }else{
            
            //NSLog(@"Unable to fetch items: %@", error.localizedDescription);
            
            //[self showMessage:@"Unable to find new items, please try again later" withTitle:@"Error"];
            
        }
        
    }];
}

- (NSArray *)getMessages {
    return _conversationMessages;
}


@end
