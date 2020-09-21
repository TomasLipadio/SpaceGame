//
//  HUDNode.h
//  SpaceGame
//
//  Created by Никита Шарапов on 10.11.15.
//  Copyright © 2015 Никита Шарапов. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface HUDNode : SKNode

-(void)addPoints:(NSInteger)points;
-(void)startGame;
-(void)endGame;

-(void)showPowerTimer:(NSTimeInterval)time;
-(void)showDoubleFireTimer:(NSTimeInterval)time;

-(void)layoutControls;

@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic) NSInteger score;

@property (nonatomic, strong) NSNumberFormatter *scoreFormatter;
@property (nonatomic, strong) NSNumberFormatter *timeFormatter;

@end
