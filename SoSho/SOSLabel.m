//
//  SOSLabel.m
//  SoSho
//
//  Created by Mikko Malmari on 31.10.2014.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSLabel.h"

@implementation SOSLabel

int width;
int maxWidth = 256;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIEdgeInsets insets = {0, 5, 0, 5};
    CGRect foo = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    return [super drawTextInRect:UIEdgeInsetsInsetRect(foo, insets)];
}


- (CGSize) intrinsicContentSize{
    CGSize s = [super intrinsicContentSize];
    return CGSizeMake(s.width+10, s.height);
}


@end
