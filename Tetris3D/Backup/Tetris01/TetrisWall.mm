//
//  TetrisWall.m
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "TetrisWall.h"

@implementation TetrisWall

- (id)initWithDimension:(GLKVector3)dim {
    self = [super init];
    
    mXp = mZp = 0;
    mYp = -0.5;
    mXr = mYr = mZr = 0;
    mXs = dim.x;
    mYs = dim.y;
    mZs = dim.z;
    
    mColor = GLKVector4Make(1, 1, 1, 0.25);
    
    return self;
}

- (void)onDraw:(GLKMatrix4)viewMatrix {
    // perform model view transformation
    // Compute the model view matrix for the object rendered with ES2
    GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(mXp, mYp, mZp);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mXr, 1.0f, 0.0f, 0.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mYr, 0.0f, 1.0f, 0.0f);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, mZr, 0.0f, 0.0f, 1.0f);
    modelMatrix = GLKMatrix4Scale(modelMatrix, mXs, mYs, mZs);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
    modelViewMatrix = GLKMatrix4Multiply(mBaseViewMatrix, modelViewMatrix);
    
    // calculate normal and MVP matrices
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(mProjectionMatrix, modelViewMatrix);
    
    // pass matrices to GL shaders
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniform4f(uniforms[UNIFORM_COLOR_VECTOR], mColor.r, mColor.g, mColor.b, mColor.a);
    
    // draw
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

@end
