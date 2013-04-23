//
//  PieceView.h
//  Tetris360
//
//  Created by Liang Shi on 4/22/13.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kGridSize 32
typedef enum{
    PieceTypeI = 0, // □□□□

    PieceTypeO = 1, // □□
                    // □□
    
    PieceTypeJ = 2, // □
                    // □□□
    
    PieceTypeL = 3, //   □
                    // □□□

    PieceTypeS = 4, //  □□
                    // □□

    PieceTypeZ = 5, // □□
                    //  □□

    PieceTypeT = 6 //   □
                   //  □□□
    
} PieceType;


@interface PieceView : UIView

@property (nonatomic, assign) PieceType pieceType;
@property (nonatomic, assign) CGPoint pieceOriginLocation;

- (id)initWithPieceType:(PieceType)type;


@end
