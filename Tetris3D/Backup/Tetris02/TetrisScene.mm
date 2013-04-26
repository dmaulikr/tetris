//
//  TetrisScene.m
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-25.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "TetrisScene.h"

@implementation TetrisScene

- (void)onUpdate:(float)delaTime {
    // what the object should do on update
    for (TetrisDrawable *drawableObject in mContainer) {
        [drawableObject onUpdate:delaTime];
    }
}

- (void)onDraw:(GLKMatrix4)viewMatrix {
    mXp -= mXpAdd;
    mZp -= mZpAdd;
    mXr -= mXrAdd;
    mYr -= mYrAdd;
    mZr -= mZrAdd;
    mXpAdd = mYpAdd = mZpAdd = 0;
    mXrAdd = mYrAdd = mZrAdd = 0;
    
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
}

- (void)add:(TetrisDrawable *)drawableObject {
    [mContainer addObject:drawableObject];
}

@end
