//
//  SOSFacebookFriend.h
//  SoSho
//
//  Created by Artur Minasjan on 25/08/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSFacebookFriend : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSArray *messagesHistory;
- (id)initWithName:(NSString *)name andImageUrl:(NSString *)url;
@end
