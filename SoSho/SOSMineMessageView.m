//
//  SOSMineMessageView.m
//  SoSho
//
//  Created by Artur Minasjan on 06/10/14.
//  Copyright (c) 2014 SoSho. All rights reserved.
//

#import "SOSMineMessageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SOSMineMessageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        _frame = frame;
    }
    return self;
}


//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
////    CGContextRef context = UIGraphicsGetCurrentContext();
////    CGRect rectangle = CGRectMake(0,0,200,80);
////    CGContextAddRect(context, rectangle);
////    CGContextStrokePath(context);
////    CGContextSetFillColorWithColor(context,
////                                   [UIColor redColor].CGColor);
////    CGContextFillRect(context, rectangle);
////    
////    
////    CGContextRef ctx = UIGraphicsGetCurrentContext();
////    
////    CGContextBeginPath(ctx);
////    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
////    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect));  // mid right
////    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // bottom left
////    CGContextClosePath(ctx);
////    
////    CGContextSetRGBFillColor(ctx, 1, 1, 0, 1);
////    CGContextFillPath(ctx);
//    
//    // Get the context
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // Pick colors
//    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
//    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
//    
//    // Define triangle dimensions
//    CGFloat baseWidth = 30.0;
//    CGFloat height = 20.0;
//    
//    // Define path
//    CGContextMoveToPoint(context, self.bounds.size.width / 2.0 - baseWidth / 2.0,
//                         self.bounds.size.height - height);
//    CGContextAddLineToPoint(context, self.bounds.size.width / 2.0 + baseWidth / 2.0,
//                            self.bounds.size.height - height);
//    CGContextAddLineToPoint(context, self.bounds.size.width / 2.0,
//                            self.bounds.size.height);
//    
//    // Finalize and draw using path
//    CGContextClosePath(context);
//    CGContextStrokePath(context);
//}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context=UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(context, .5f);
//    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
//    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    
    
    
    // Drawing with a white stroke color
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    // Draw a bezier curve with end points s,e and control points cp1,cp2
    CGPoint s = CGPointMake(30.0, 120.0);
    CGPoint e = CGPointMake(300.0, 120.0);
    CGPoint cp1 = CGPointMake(120.0, 30.0);
    CGPoint cp2 = CGPointMake(210.0, 210.0);
    CGContextMoveToPoint(context, s.x, s.y);
    CGContextAddCurveToPoint(context, cp1.x, cp1.y, cp2.x, cp2.y, e.x, e.y);
    CGContextStrokePath(context);
    
    // Show the control points.
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextMoveToPoint(context, s.x, s.y);
    CGContextAddLineToPoint(context, cp1.x, cp1.y);
    CGContextMoveToPoint(context, e.x, e.y);
    CGContextAddLineToPoint(context, cp2.x, cp2.y);
    CGContextStrokePath(context);
    
    // Draw a quad curve with end points s,e and control point cp1
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    s = CGPointMake(30.0, 300.0);
    e = CGPointMake(270.0, 300.0);
    cp1 = CGPointMake(150.0, 180.0);
    CGContextMoveToPoint(context, s.x, s.y);
    CGContextAddQuadCurveToPoint(context, cp1.x, cp1.y, e.x, e.y);
    CGContextStrokePath(context);
    
    // Show the control point.
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextMoveToPoint(context, s.x, s.y);
    CGContextAddLineToPoint(context, cp1.x, cp1.y);
    CGContextStrokePath(context);
    
}


@end
