//
//  GameStartNode.m
//  SpaceGame
//
//  Created by Никита Шарапов on 04.11.15.
//  Copyright © 2015 Никита Шарапов. All rights reserved.
//

#import "GameStartNode.h"

@implementation GameStartNode

-(instancetype)init
{
    if (self = [super init]) {
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Copperplate"];
        label.fontSize = 70;
        label.fontColor = [SKColor whiteColor];
        label.text = @"Кораблик";
        [self addChild:label];
        
        label.alpha = 0;
        label.xScale = 0.2;
        label.yScale = 0.2;
        SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:3];
        SKAction *scaleIn = [SKAction scaleTo:1 duration:2];
        SKAction *fadeAndScale = [SKAction group:@[fadeIn, scaleIn]];
        [label runAction:fadeAndScale];
        
        SKLabelNode *instructions = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Heavy"];
        instructions.fontSize = 24;
        instructions.fontColor = [SKColor whiteColor];
        instructions.text = @"Tap for START game.";
        instructions.position = CGPointMake(0, -45);
        [self addChild:instructions];
        
        instructions.alpha = 0;
        SKAction *wait = [SKAction waitForDuration:2];
        SKAction *appear = [SKAction fadeAlphaTo:1 duration:0.2];
        SKAction *popUp = [SKAction scaleTo:1.1 duration:0.1];
        SKAction *dropDown = [SKAction scaleTo:1 duration:0.1];
        SKAction *pauseAndAppear = [SKAction sequence:@[wait, appear, popUp, dropDown]];
        SKAction *repeatForEver = [SKAction repeatActionForever:pauseAndAppear];
        [instructions runAction:repeatForEver];
        }
    return self;
}

@end
