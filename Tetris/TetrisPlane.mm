//
//  TetrisPlane.m
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-25.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "TetrisPlane.h"

@implementation TetrisPlane

- (id)init {
    self = [super init];
    
    // create L blocks
    GLKVector4 color = GLKVector4Make(1, 0.25, 0.25, 1);
    TetrisDrawable *block;
    for (int x = 0; x < CONTAINER_DIM; x++) {
        for (int z = 0; z < CONTAINER_DIM-1; z++) {
            // add block
            block = [TetrisDrawable new];
            [block setPosition:x-CONTAINER_OFFSET :0 :z-CONTAINER_OFFSET];
            [block setColor:color];
            [self add:block];
        }
    }
    
    return self;
}

@end
