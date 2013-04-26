//
//  TetrisDrawableContainer.m
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "TetrisContainer.h"
#import "TetrisPieceFactory.h"

TetrisContainer *sCurrentTetrisPiece;

@implementation TetrisContainer

- (id)init {
    self = [super init];
    
    mContainer = [[NSMutableArray alloc] init];
    mTimeSinceLastMove = 0;
    
    return self;
}

- (void)onUpdate:(float)delaTime {
    if (self == sCurrentTetrisPiece) {
        mTimeSinceLastMove += delaTime;
        if (mTimeSinceLastMove > FALL_RATE) {
            mTimeSinceLastMove = 0;
            mYpAdd -= 1;
        }
    }
}

- (void)onDraw:(GLKMatrix4)viewMatrix {
    bool isFalling = (self == sCurrentTetrisPiece);
    if (isFalling) {
        // unoccupy
        for (TetrisDrawable *baseBlock in mContainer) {
            [baseBlock updateOccupiedPosition:false];
        }
        
        // update offsets
        mXp += mXpAdd;
        mZp += mZpAdd;
        mXr += mXrAdd;
        mYr += mYrAdd;
        mZr += mZrAdd;
    }
    
    // perform model view transformation
    // Compute the model view matrix for the object rendered with ES2
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(mXp, mYp, mZp);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, mXr, 1.0f, 0.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, mYr, 0.0f, 1.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, mZr, 0.0f, 0.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, mXs, mYs, mZs);
    modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelViewMatrix);
     
    for (TetrisDrawable *drawableObject in mContainer) {
        [drawableObject onDraw:modelViewMatrix];
    }
    
    if (isFalling) {
        bool validSpace = true;
        for (TetrisDrawable *baseBlock in mContainer) {
            validSpace = validSpace && [baseBlock isValidSpace];
        }
        
        if (!validSpace) {
            // undo moves
            mXp -= mXpAdd;
            mZp -= mZpAdd;
            mXr -= mXrAdd;
            mYr -= mYrAdd;
            mZr -= mZrAdd;
            
            modelViewMatrix = GLKMatrix4MakeTranslation(mXp, mYp, mZp);
            modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, mXr, 1.0f, 0.0f, 0.0f);
            modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, mYr, 0.0f, 1.0f, 0.0f);
            modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, mZr, 0.0f, 0.0f, 1.0f);
            modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, mXs, mYs, mZs);
            modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelViewMatrix);
            
            // force another draw to update child absolut positions
            for (TetrisDrawable *drawableObject in mContainer) {
                [drawableObject onDraw:modelViewMatrix];
            }
        }
        
        if (mYpAdd < 0) {
            for (TetrisDrawable *baseBlock in mContainer) {
                isFalling = isFalling && [baseBlock isFallable];
            }
            if (isFalling) {
                mYp += mYpAdd;
            } else {
                mYpAdd = 0;
                [TetrisPieceFactory SpawnPiece:(arc4random()%PIECE_NUM)];
            }
        }
        
        for (TetrisDrawable *baseBlock in mContainer) {
            baseBlock->mYa += mYpAdd;
            [baseBlock updateOccupiedPosition:true];
        }
    }
    mXpAdd = mYpAdd = mZpAdd = 0;
    mXrAdd = mYrAdd = mZrAdd = 0;
}

- (void)add:(TetrisDrawable *)drawableObject {
    [mContainer addObject:drawableObject];
}

@end
