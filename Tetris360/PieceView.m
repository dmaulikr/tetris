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
        self.pieceRotated = PieceOriginal;
        self.blocksCenter = [[NSMutableArray alloc] initWithCapacity:kNUMBER_OF_BLOCKS];
        for (int i = 0; i < kNUMBER_OF_BLOCKS; i++) {
            CGPoint point = CGPointMake(0, 0);
            [self.blocksCenter addObject:[NSValue valueWithCGPoint:point]];
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
    self.pieceCenter = CGPointMake(1.5*kGridSize, 1.5*kGridSize);
    //draw each piece based on piece type
    CGRect rectangle;
    CGContextRef context = UIGraphicsGetCurrentContext();
//    [[UIColor blackColor] setStroke];
    [[PieceView getColorOfType:self.pieceType] setFill];
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
            rectangle = CGRectMake(0, 0, kGridSize, kGridSize);
            CGContextClearRect(context, rectangle);
            rectangle = CGRectMake(kGridSize * 2, 0, kGridSize, kGridSize);
            CGContextClearRect(context, rectangle);
            break;
        case PieceTypeZ:
            rectangle = CGRectMake(0, kGridSize, kGridSize, kGridSize);
            CGContextClearRect(context, rectangle);
            rectangle = CGRectMake(kGridSize * 2, 0, kGridSize, kGridSize);
            CGContextClearRect(context, rectangle);
            break;
        case PieceTypeI:
            self.pieceCenter = CGPointMake(1.5*kGridSize, 0.5*kGridSize);
            break;
        case PieceTypeO:
            self.pieceCenter = CGPointMake(kGridSize, kGridSize);
            break;
        default:
            break;
    }
    
}


#pragma mark - touch events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.layer.anchorPoint = self.pieceCenter;

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
