//
//  ViewController.m
//  Tetris360
//
//  Created by Liang Shi on 2013-04-21.
//  Copyright (c) 2013 Gree. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)generatePiece:(id)sender{
    //remove old pieces
    for (UIView *subview in [self.view subviews]) {
        if ([subview isKindOfClass:[PieceView class]]) {
            [subview removeFromSuperview];
        }
    }

    //generate a random tetris piece
    int randomNumber = rand()%7; //7 types of pieces

    PieceView *onePieceView = [[PieceView alloc] initWithPieceType:randomNumber];

    [self.view addSubview: onePieceView];
}


@end
