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


@interface PieceView : UIView

@property (nonatomic, assign) PieceType pieceType;
@property (nonatomic, assign) CGPoint pieceOriginLocation;

- (id)initWithPieceType:(PieceType)type;


@end
