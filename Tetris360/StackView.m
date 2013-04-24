//
//  StackView.m
//  Tetris360
//
//  Created by Liang Shi on 4/24/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import "StackView.h"
#import "GameController.h"

@implementation StackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    for (int i = 0; i < kNUMBER_OF_ROW; i++) {
        for (int j = 0; j < kNUMBER_OF_COLUMN; j++) {

            PieceType type = [[GameController alloc] getTypeAtRow:i andColumn:j];
            CGRect rectangle = CGRectMake(j * kGridSize, i * kGridSize, kGridSize, kGridSize);
            
            if (type != PieceTypeNone) {
                UIColor *color = [PieceView getColorOfType:type];
                CGContextSetFillColorWithColor(context, color.CGColor);
                CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
                CGContextFillRect(context, rectangle);
            }
            
            if (i == kNUMBER_OF_ROW - 1) {
                CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
                CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
                NSString *columnNumber = [NSString stringWithFormat:@"%d", j];
                [columnNumber drawInRect:rectangle withFont:[UIFont systemFontOfSize:14]];
                CGContextStrokeRect(context, rectangle);
            }
        }
    }
    
}


@end
