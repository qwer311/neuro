//
//  GraphView.m
//  graphtest
//
//  Created by yuppon on 2014/12/5.
//  Copyright (c) 2014 yuppon. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)drawRect:(CGRect)rect
{

    CGContextRef ctx = UIGraphicsGetCurrentContext();

//    CGContextSetFillColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
//    CGContextFillRect(ctx, rect);

    double o_x = 140.0;
    double o_y = 172.0;
    double size = 100;
    
    double p1_x = o_x + 0.0 * m1 / 100 / 100 * size;
    double p1_y = o_y - 100.0 * m1 / 100 / 100 * size;
    double p2_x = o_x - 96.1 * m2 / 100 / 100 * size;
    double p2_y = o_y - 21.9 * m2 / 100 / 100 * size;

    double p3_x = o_x - 58.8 * m3 / 100 / 100 * size;
    double p3_y = o_y + 89.9 * m3 / 100 / 100 * size;
    double p4_x = o_x + 58.8 * m4 / 100 / 100 * size;
    double p4_y = o_y + 89.9 * m4 / 100 / 100 * size;
    
    double p5_x = o_x + 96.1 * m5 / 100 / 100 * size;
    double p5_y = o_y - 21.9 * m5 / 100 / 100 * size;
    
    CGContextSetRGBFillColor(ctx, 0, 0.26, 0.57, 0.8);
    CGContextMoveToPoint(ctx, p1_x, p1_y);
    CGContextAddLineToPoint(ctx, p1_x, p1_y);
    CGContextAddLineToPoint(ctx, p2_x, p2_y);
    CGContextAddLineToPoint(ctx, p3_x, p3_y);
    CGContextAddLineToPoint(ctx, p4_x, p4_y);
    CGContextAddLineToPoint(ctx, p5_x, p5_y);
    CGContextAddLineToPoint(ctx, p1_x, p1_y);
    CGContextFillPath(ctx);
    
}

@end
