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
                point = CGPointMake(0, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(2, 1);
                [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
                point = CGPointMake(3, 1);
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

    if (self.pieceType != PieceTypeO) {
        // Repositions and resizes the view.
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.1];
        
        switch (self.pieceRotated) {
            case PieceOriginal:
                self.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
//                [self setFrame:CGRectMake(self.frame.origin.x + kGridSize / 2.0, self.frame.origin.y + kGridSize / 2.0, self.frame.size.width, self.frame.size.height)];
                self.pieceRotated = PieceRotateOnce;
                break;
            case PieceRotateOnce:
                self.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
                self.pieceRotated = PieceRotateTwice;
                break;
            case PieceRotateTwice:
                self.transform = CGAffineTransformMakeRotation(DegreesToRadians(270));
//                [self setFrame:CGRectMake(self.frame.origin.x - kGridSize / 2.0, self.frame.origin.y - kGridSize / 2.0, self.frame.size.width, self.frame.size.height)];
                self.pieceRotated = PieceRotateThreeTimes;
                break;
            case PieceRotateThreeTimes:
                self.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
                self.pieceRotated = PieceOriginal;
                break;
            default:
                break;
        }

        [UIView commitAnimations];
    }
}

@end
