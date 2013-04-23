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
@synthesize movingPieceView;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startGameClickeed:(id)sender{
    if ([[GameController shareManager] gameStatus] == GameRunning) {
        [[GameController shareManager] pauseGame];
        [[GameController shareManager] setGameStatus:GamePaused];
        [self.startButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    else if([[GameController shareManager] gameStatus] == GamePaused) {
        [[GameController shareManager] startGame];
        [[GameController shareManager] setGameStatus:GameRunning];
        [self.startButton setTitle:@"Pause" forState:UIControlStateNormal];
        movingPieceView = [[GameController shareManager] generatePiece];
        [self.view addSubview:movingPieceView];
    }
}

- (IBAction)leftClicked:(id)sender{
    [[GameController shareManager] movePieceLeft];
}


- (IBAction)rightClicked:(id)sender{
    [[GameController shareManager] movePieceRight];
}

@end
