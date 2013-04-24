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

    for (int i = 0; i < kNUMBER_OF_ROW; i++) {
        for (int j = 0; j < kNUMBER_OF_COLUMN; j++) {
            int type = [[GameController alloc] getTypeAtLocationX:j andY:i];
            if (type) {
                CGRect rectangle = CGRectMake(i * kGridSize, j * kGridSize, kGridSize, kGridSize);
                [[PieceView getColorOfType:type] setFill];
                UIRectFill( rectangle );
            }

        }
    }
    
}


@end
