//
//  TetrisDrawableContainer.h
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "TetrisDrawable.h"

@interface TetrisContainer : TetrisDrawable {
    NSMutableArray *mContainer;
    float mTimeSinceLastMove;
}

- (void)add:(TetrisDrawable *)drawableObject;


@end

extern TetrisContainer *sCurrentTetrisPiece;
