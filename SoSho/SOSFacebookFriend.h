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
@property (nonatomic, copy) NSString* id;
- (id)initWithName:(NSString *)name ImageUrl:(NSString *)url andId:(NSString *)id;
- (void)setMessagesHistory:(NSArray *)messagesHistory;
@end
