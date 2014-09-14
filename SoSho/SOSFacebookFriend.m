//
//  SOSFacebookFriend.m
//  SoSho
//
//  Created by Artur Minasjan on 25/08/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSFacebookFriend.h"

@implementation SOSFacebookFriend
- (id)initWithName:(NSString *)name ImageUrl:(NSString *) url andId:(NSString *)id{
    self = [super init];
    if(self) {
        _name = name;
        _imageUrl = url;
        _id = id;
        return self;
    }
    return nil;
}

- (void)setMessagesHistory:(NSArray *)messagesHistory {
    _messagesHistory = messagesHistory;
}

@end
