//
//  TetrisDrawable.h
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define CONTAINER_DIM       11
#define CONTAINER_OFFSET    5
#define FALL_RATE           0.1

typedef enum {
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_COLOR_VECTOR,
    NUM_UNIFORMS
} UNIFORM_TYPE;

extern GLint uniforms[NUM_UNIFORMS];
extern GLKMatrix4 mBaseViewMatrix;;
extern GLKMatrix4 mProjectionMatrix;

@interface TetrisDrawable : NSObject {
@public
    int   mXa, mYa, mZa;    // absolute position
@protected
    float mXp, mYp, mZp;    // position
    float mXr, mYr, mZr;    // rotation
    float mXs, mYs, mZs;    // scaling
    
    float mXpAdd, mYpAdd, mZpAdd;   // add offset position
    float mXrAdd, mYrAdd, mZrAdd;   // add offset rotation
    
    GLKVector4 mColor;      // color
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
}

- (void)addPosition:(float)x :(float)y :(float)z;
- (void)setPosition:(float)x :(float)y :(float)z;
- (void)addRotation:(float)x :(float)y :(float)z;
- (void)setColor:(GLKVector4)color;
- (void)onUpdate:(float)delaTime;
- (bool)isValidSpace;
- (bool)isFallable;
- (void)updateOccupiedPosition:(bool)flag;
- (void)onDraw:(GLKMatrix4)viewMatrix;

@end

struct cell {
    bool isOccupied;
    TetrisDrawable *mWho;
    
    // constructor
    cell() {
        isOccupied = false;
        mWho = nil;
    }
};
extern cell ****Cells;
