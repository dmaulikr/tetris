//
//  TetrisCube.m
//  Tetris
//
//  Created by Yuan Yeh on 2013-04-24.
//  Copyright (c) 2013 teamtetris. All rights reserved.
//

#import "TetrisO.h"

@implementation TetrisO

- (id)init {
    self = [super init];
    
    // create L blocks
    GLKVector4 color = GLKVector4Make(0.25, 0.25, 1, 1);
    TetrisDrawable *block;
    // block 1
    block = [TetrisDrawable new];
    [block setPosition:0 :0 :0];
    [block setColor:color];
    [self add:block];
    // block 2
    block = [TetrisDrawable new];
    [block setPosition:0 :1 :0];
    [block setColor:color];
    [self add:block];
    // block 3
    block = [TetrisDrawable new];
    [block setPosition:1 :0 :0];
    [block setColor:color];
    [self add:block];
    // block 4
    block = [TetrisDrawable new];
    [block setPosition:1 :1 :0];
    [block setColor:color];
    [self add:block];
    // block 5
    block = [TetrisDrawable new];
    [block setPosition:0 :0 :1];
    [block setColor:color];
    [self add:block];
    // block 6
    block = [TetrisDrawable new];
    [block setPosition:0 :1 :1];
    [block setColor:color];
    [self add:block];
    // block 7
    block = [TetrisDrawable new];
    [block setPosition:1 :0 :1];
    [block setColor:color];
    [self add:block];
    // block 8
    block = [TetrisDrawable new];
    [block setPosition:1 :1 :1];
    [block setColor:color];
    [self add:block];
    
    return self;
}

@end
