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

@end

@implementation SOSFacebookFriendsDataController

- (id)init {
    self = [super init];
    
    if(self) {
        _friendsList = [[NSMutableArray alloc] init];
        
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


@end
