//
//  SOSFacebookFriendsDataController.h
//  SoSho
//
//  Created by Artur Minasjan on 25/08/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SOSFacebookFriend;

@interface SOSFacebookFriendsDataController : NSObject
- (NSUInteger)friendsCount;
- (SOSFacebookFriend *)friendAtIndex:(NSUInteger)index;
- (NSArray *)allFriendsList;
- (void)addFriend:(NSString *)name withImage:(NSString *)image andId:(NSString *)id;
- (void)fetchMessages;
- (NSArray *)getMessages;
@end
