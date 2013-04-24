//
//  PieceView.m
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import "PieceView.h"
#import "GameController.h"

@implementation PieceView


- (id)initWithPieceType:(PieceType)type{
    self.pieceType = type;
    CGRect frame = CGRectMake(4*kGridSize, 0, kGridSize, kGridSize);
    switch (type) {
        case PieceTypeI:
            frame = CGRectMake(3*kGridSize, 0, kGridSize * 4, kGridSize);
            break;
        case PieceTypeO:
            frame = CGRectMake(4*kGridSize, 0, kGridSize * 2, kGridSize * 2);
            break;
        case PieceTypeJ:
        case PieceTypeL:
        case PieceTypeS:
        case PieceTypeT:
        case PieceTypeZ:
            frame = CGRectMake(3*kGridSize, 0, kGridSize * 3, kGridSize * 2);
            break;
        default:
            break;
    }
    
    return [self initWithFrame:frame];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


- (UIColor*)getColorOfType: (PieceType)type{
    switch (type) {
        case PieceTypeI:
            return [UIColor redColor];
            break;
        case PieceTypeO:
            return [UIColor orangeColor];
            break;
        case PieceTypeJ:
            return [UIColor yellowColor];
            break;
        case PieceTypeL:
            return [UIColor greenColor];
            break;
        case PieceTypeS:
            return [UIColor blueColor];
            break;
        case PieceTypeT:
            return [UIColor purpleColor];
            break;
        case PieceTypeZ:
            return [UIColor cyanColor];
            break;
        default:
            return nil;
            break;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //draw each piece based on piece type
    CGRect rectangle;
    CGContextRef context = UIGraphicsGetCurrentContext();
//    [[UIColor blackColor] setStroke];
    [[self getColorOfType:self.pieceType] setFill];
    UIRectFill( rect );
    switch (self.pieceType) {
        case PieceTypeJ:
            rectangle = CGRectMake(kGridSize, 0, kGridSize * 2, kGridSize);
            CGContextClearRect(context, rectangle);
            break;
        case PieceTypeL:
            rectangle = CGRectMake(0, 0, kGridSize * 2, kGridSize);
            CGContextClearRect(context, rectangle);
            break;
        case PieceTypeS:
            rectangle = CGRectMake(0, 0, kGridSize, kGridSize);
            CGContextClearRect(context, rectangle);
            rectangle = CGRectMake(kGridSize * 2, kGridSize, kGridSize, kGridSize);
            CGContextClearRect(context, rectangle);
            break;
        case PieceTypeT:
            rectangle = CGRectMake(0, kGridSize, kGridSize, kGridSize);
            CGContextClearRect(context, rectangle);
            rectangle = CGRectMake(kGridSize * 2, 0, kGridSize, kGridSize);
            CGContextClearRect(context, rectangle);
            break;
        case PieceTypeZ:
            rectangle = CGRectMake(0, 0, kGridSize, kGridSize);
            CGContextClearRect(context, rectangle);
            rectangle = CGRectMake(kGridSize * 2, 0, kGridSize, kGridSize);
            CGContextClearRect(context, rectangle);
            break;
        case PieceTypeI:
        case PieceTypeO:
        default:
            break;
    }
    
}



@end
