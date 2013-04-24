//
//  StackView.m
//  Tetris360
//
//  Created by Liang Shi on 4/24/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import "StackView.h"

@implementation StackView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[PieceView getColorOfType:self.currentPieceType] setFill];
    UIRectFill( rect );
}


@end
