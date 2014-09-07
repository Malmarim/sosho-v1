//
//  SOSFacebookFriend.m
//  SoSho
//
//  Created by Artur Minasjan on 25/08/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSFacebookFriend.h"

@implementation SOSFacebookFriend
- (id)initWithName:(NSString *)name andImageUrl:(NSString *) url{
    self = [super init];
    if(self) {
        _name = name;
        _imageUrl = url;
        return self;
    }
    return nil;
}

@end
