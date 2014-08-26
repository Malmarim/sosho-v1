//
//  SOSFacebookFriendsDataController.m
//  SoSho
//
//  Created by Artur Minasjan on 25/08/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSFacebookFriendsDataController.h"
#import "SOSFacebookFriend.h"
@interface SOSFacebookFriendsDataController ()

@property (nonatomic, readonly) NSMutableArray *friendsList;
- (void)initializeDefaultFriends;

@end

@implementation SOSFacebookFriendsDataController

- (id)init {
    self = [super init];
    
    if(self) {
        _friendsList = [[NSMutableArray alloc] init];
        [self initializeDefaultFriends];
        
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

- (void)initializeDefaultFriends {
    SOSFacebookFriend *friend = [[SOSFacebookFriend alloc] initWithName:@"Jonh Doe"];
    [self.friendsList addObject:friend];
}


@end
