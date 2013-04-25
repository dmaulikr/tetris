//
//  PieceView.m
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import "PieceView.h"
#import "GameController.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@implementation PieceView
@synthesize blocksCenter = _blocksCenter;

- (id)initWithPieceType:(PieceType)type pieceCenter:(CGPoint)center {
    self.pieceType = type;
    self.pieceCenter = center;
    CGRect frame;
    switch (type) {
        case PieceTypeI:
            frame = CGRectMake(kGridSize*center.x, kGridSize*center.y, kGridSize * 4, kGridSize * 2);
            break;
        case PieceTypeO:
            frame = CGRectMake(kGridSize*center.x, kGridSize*center.y, kGridSize * 2, kGridSize * 2);
            break;
        case PieceTypeJ:
        case PieceTypeL:
        case PieceTypeS:
        case PieceTypeT:
        case PieceTypeZ:
            frame = CGRectMake(kGridSize*center.x, kGridSize*center.y, kGridSize * 3, kGridSize * 2);
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
        self.pieceRotated = PieceOriginal;
        //initializing blocks
        self.blocksCenter = [[NSMutableArray alloc] initWithCapacity:kNUMBER_OF_BLOCKS];
        CGPoint point = CGPointMake(1, 1);
        [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];

        switch (self.pieceType) {
            case PieceTypeJ:
                point = CGPointMake(0, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(0, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(2, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                break;
            case PieceTypeL:
                point = CGPointMake(0, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(2, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(2, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                break;
            case PieceTypeS:
                point = CGPointMake(0, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(1, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(2, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                break;
            case PieceTypeT:
                point = CGPointMake(0, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(2, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(1, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                break;
            case PieceTypeZ:
                point = CGPointMake(0, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(1, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(2, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                break;
            case PieceTypeI:
                point = CGPointMake(1, 0);
                self.blocksCenter[0] = [NSValue valueWithCGPoint:point];
                point = CGPointMake(0, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(2, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(3, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                break;
            case PieceTypeO:
                point = CGPointMake(0, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(0, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(1, 0);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                break;
            default:
                break;
        }

    }
    return self;
}


+ (UIColor*)getColorOfType: (PieceType)type{
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
    [[UIColor whiteColor] setStroke];
    [[PieceView getColorOfType:self.pieceType] setFill];

    for (int i = 0; i < kNUMBER_OF_BLOCKS; i++) {
        //draw each block
        rectangle = CGRectMake(([[self.blocksCenter objectAtIndex:i] CGPointValue].x) * kGridSize, ([[self.blocksCenter objectAtIndex:i] CGPointValue].y) * kGridSize, kGridSize, kGridSize);
        CGContextFillRect(context, rectangle);
        CGContextStrokeRect(context, rectangle);
    }
}


#pragma mark - touch events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    //rotate the piece 90 degrees clockwise
    if (self.pieceType == PieceTypeI) {
        
    }
    else if (self.pieceType != PieceTypeO) {
        for (int i = 1; i < kNUMBER_OF_BLOCKS; i++) {
            int x = [self.blocksCenter[i] CGPointValue].x;
            int y = [self.blocksCenter[i] CGPointValue].y;

            //up down left right
            if (x == 1 && y == 0) {
                x = 2; y = 1;
            }
            else if (x == 2 && y == 1){
                x = 1;  y = 2;
            }
            else if(x == 1 && y == 2){
                x = 0; y = 1;
            }
            else if(x == 0 && y == 1){
                x = 1; y = 0;
            }
            //for corners
            if (x == 0 && y == 0) {
                x = 2; y = 0;
            }
            else if (x == 2 && y == 0){
                x = 2;  y = 2;
            }
            else if(x == 2 && y == 2){
                x = 0; y = 2;
            }
            else if(x == 0 && y == 2){
                x = 0; y = 0;
            }
            
            CGPoint newPoint = CGPointMake(x, y);
            self.blocksCenter[i] = [NSValue valueWithCGPoint:newPoint];
        }
    }

    [self setNeedsDisplay];

}

@end
