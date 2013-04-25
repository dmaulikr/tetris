//
//  PieceView.h
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kGridSize 32
#define kNUMBER_OF_BLOCKS 4


typedef enum{
    PieceTypeNone = 0,
    PieceTypeI, // □□□□

    PieceTypeO, // □□
                // □□
    
    PieceTypeJ, // □
                // □□□
    
    PieceTypeL, //   □
                // □□□

    PieceTypeS,  //  □□
                 // □□

    PieceTypeZ, // □□
                //  □□

    PieceTypeT //   □
              //  □□□
    
} PieceType;


typedef enum{
    PieceOriginal = 0,
    PieceRotateOnce,
    PieceRotateTwice,
    PieceRotateThreeTimes
}PieceRotation;

@interface PieceView : UIView

@property (nonatomic, assign) PieceType pieceType;
@property (nonatomic, assign) PieceRotation pieceRotated;
@property (nonatomic, assign) CGPoint pieceCenter;
@property (nonatomic, retain) NSMutableArray *blocksCenter;

- (id)initWithPieceType:(PieceType)type;
+ (UIColor*)getColorOfType: (PieceType)type;
@end
