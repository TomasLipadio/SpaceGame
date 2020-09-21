//
//  HUDNode.m
//  SpaceGame
//
//  Created by Никита Шарапов on 10.11.15.
//  Copyright © 2015 Никита Шарапов. All rights reserved.
//

#import "HUDNode.h"

@implementation HUDNode

-(instancetype)init{
    if (self = [super init]) {
        
        //Score Group
        SKNode *scoreGroup = [SKNode node];
        scoreGroup.name = @"scoreGroup";
        
        SKLabelNode *scoreTitle = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
        scoreTitle.fontSize = 12;
        scoreTitle.fontColor = [SKColor whiteColor];
        scoreTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        scoreTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
        //scoreTitle.text = @"SCORE";
        scoreTitle.position = CGPointMake(0, 4);
        [scoreGroup addChild:scoreTitle];
        
        
        SKLabelNode *scoreValue = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
        scoreValue.fontSize = 50;
        scoreValue.fontColor = [SKColor whiteColor];
        scoreValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        scoreValue.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        scoreValue.name = @"scoreValue";
        scoreValue.text = @"0";
        scoreValue.position = CGPointMake(0, 0);
        [scoreGroup addChild:scoreValue];
        
        [self addChild:scoreGroup];
        
        self.scoreFormatter = [[NSNumberFormatter alloc]init];
        self.scoreFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        self.timeFormatter = [[NSNumberFormatter alloc]init];
        self.timeFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.timeFormatter.minimumFractionDigits = 1;
        self.timeFormatter.maximumFractionDigits = 1;

        //Power Group
        SKNode *powerGroup = [SKNode node];
        powerGroup.name = @"powerGroup";
        SKLabelNode *powerTitle = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
        powerTitle.fontSize = 14;
        powerTitle.fontColor = [SKColor redColor];
        powerTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
        powerTitle.text = @"Power Fire!";
        powerTitle.position = CGPointMake(0, 4);
        [powerGroup addChild:powerTitle];
        
        SKLabelNode *powerValue = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
        powerValue.fontSize = 16;
        powerValue.fontColor = [SKColor whiteColor];
        powerValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        powerValue.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        powerValue.name = @"powerValue";
        powerValue.text = @"0s left";
        powerValue.position = CGPointMake(0, -4);
        [powerGroup addChild:powerValue];
        [self addChild:powerGroup];


        powerGroup.alpha = 0;
        
        SKAction *scaleUp = [SKAction scaleTo:1.3 duration:0.3];
        SKAction *scaleDown = [SKAction scaleTo:1 duration:0.3];
        SKAction *pulse = [SKAction sequence:@[scaleUp, scaleDown]];
        SKAction *pulseForever = [SKAction repeatActionForever:pulse];
        [powerTitle runAction:pulseForever];
        
    
        // Double Fire Group
        SKNode *DoubleFireGroup = [SKNode node];
        DoubleFireGroup.name = @"doubleFireGroup";
        SKLabelNode *DoubleFireTitle = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
        DoubleFireTitle.fontSize = 14;
        DoubleFireTitle.fontColor = [SKColor redColor];
        DoubleFireTitle.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
        DoubleFireTitle.text = @"Double Fire!";
        DoubleFireTitle.position = CGPointMake(0, 4);
        [DoubleFireGroup addChild:DoubleFireTitle];
        
        SKLabelNode *DoubleFireValue = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Bold"];
        DoubleFireValue.fontSize = 16;
        DoubleFireValue.fontColor = [SKColor whiteColor];
        DoubleFireValue.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        DoubleFireValue.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        DoubleFireValue.name = @"doubleFireValue";
        DoubleFireValue.text = @"0s left";
        DoubleFireValue.position = CGPointMake(0, -4);
        [DoubleFireGroup addChild:DoubleFireValue];
        [self addChild:DoubleFireGroup];
        
        DoubleFireGroup.alpha = 0;
        
        [DoubleFireTitle runAction:pulseForever];

    }
    return self;
}

-(void)addPoints:(NSInteger)points{
    self.score += points;
    SKLabelNode *scoreValue = (SKLabelNode *)[self childNodeWithName:@"scoreGroup/scoreValue"];
    scoreValue.text = [NSString stringWithFormat:@"%@", [self.scoreFormatter stringFromNumber:@(self.score)]];
    SKAction *scaleUp = [SKAction scaleTo:1.1 duration:0.02];
    SKAction *scaleDown = [SKAction scaleTo:1 duration:0.07];
    SKAction *all = [SKAction sequence:@[scaleUp, scaleDown]];
    [scoreValue runAction:all];
    
}

-(void)layoutControls{
    CGSize sceneSize = self.scene.size;
    CGSize groupSize = CGSizeZero;
    
    SKNode *scoreGroup = [self childNodeWithName:@"scoreGroup"];
    groupSize = [scoreGroup calculateAccumulatedFrame].size;
    //scoreGroup.position = CGPointMake(0 - sceneSize.width/2 + 20, sceneSize.height/2 - groupSize.height);
    scoreGroup.position = CGPointMake(0, 200);

    
    SKNode *powerGroup = [self childNodeWithName:@"powerGroup"];
    groupSize = [powerGroup calculateAccumulatedFrame].size;
    powerGroup.position = CGPointMake(sceneSize.width/2 - 80, sceneSize.height/2 - groupSize.height);
    
    SKNode *doubleFireGroup = [self childNodeWithName:@"doubleFireGroup"];
    groupSize = [doubleFireGroup calculateAccumulatedFrame].size;
    doubleFireGroup.position = CGPointMake(0, sceneSize.height/2 - groupSize.height);
}

-(void)showPowerTimer:(NSTimeInterval)time{
    SKNode *powerGroup = [self childNodeWithName:@"powerGroup"];
    SKLabelNode *powerValue = (SKLabelNode *)[powerGroup childNodeWithName:@"powerValue"];
    [powerGroup removeActionForKey:@"showPowerTimer"];
    
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    __weak HUDNode *weakSelf = self;
    SKAction *block = [SKAction runBlock:^{
        NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - start;
        NSTimeInterval left = time -elapsed;
        if (left < 0) {
            left = 0;
        }
        powerValue.text = [NSString stringWithFormat:@"%@s left", [weakSelf.timeFormatter stringFromNumber:@(left)]];
    }];
    
    SKAction *blockPause = [SKAction waitForDuration:0.05];
    SKAction *countdownSequence = [SKAction sequence:@[block, blockPause]];
    SKAction *countdown = [SKAction repeatActionForever:countdownSequence];
    
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:0.1];
    SKAction *wait = [SKAction waitForDuration:time];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:1];
    SKAction *stopAction = [SKAction runBlock:^{
        [powerGroup removeActionForKey:@"showPowerTimer"];
    }];
    
    SKAction *visuals = [SKAction sequence:@[fadeIn, wait, fadeOut, stopAction]];
    [powerGroup runAction:[SKAction group:@[countdown, visuals]] withKey:@"showPowerTimer"];
    
}

-(void)showDoubleFireTimer:(NSTimeInterval)time{
    SKNode *doubleFireGroup = [self childNodeWithName:@"doubleFireGroup"];
    SKLabelNode *doubleFireValue = (SKLabelNode *)[doubleFireGroup childNodeWithName:@"doubleFireValue"];
    [doubleFireGroup removeActionForKey:@"showDoubleFireTimer"];
    
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    __weak HUDNode *weakSelf = self;
    SKAction *block = [SKAction runBlock:^{
        NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - start;
        NSTimeInterval left = time -elapsed;
        if (left < 0) {
            left = 0;
        }
        doubleFireValue.text = [NSString stringWithFormat:@"%@s left", [weakSelf.timeFormatter stringFromNumber:@(left)]];
    }];
    
    SKAction *blockPause = [SKAction waitForDuration:0.05];
    SKAction *countdownSequence = [SKAction sequence:@[block, blockPause]];
    SKAction *countdown = [SKAction repeatActionForever:countdownSequence];
    
    SKAction *fadeIn = [SKAction fadeAlphaTo:1 duration:0.1];
    SKAction *wait = [SKAction waitForDuration:time];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:1];
    SKAction *stopAction = [SKAction runBlock:^{
        [doubleFireGroup removeActionForKey:@"showDoubleFireTimer"];
    }];
    
    SKAction *visuals = [SKAction sequence:@[fadeIn, wait, fadeOut, stopAction]];
    [doubleFireGroup runAction:[SKAction group:@[countdown, visuals]] withKey:@"showDoubleFireTimer"];
    
}

-(void)startGame{
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    __weak HUDNode *weakSelf = self;
    SKAction *update = [SKAction runBlock:^{
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        NSTimeInterval elapsed = now - startTime;
        weakSelf.elapsedTime = elapsed;
    }];
    
    SKAction *delay = [SKAction waitForDuration:0.05];
    SKAction *updateAndDelay = [SKAction sequence:@[update, delay]];
    SKAction *timer = [SKAction repeatActionForever:updateAndDelay];
    [self runAction:timer withKey:@"elapsedGameTimer"];
}

-(void)endGame{
    SKNode *powerGroup = [self childNodeWithName:@"powerGroup"];
    [powerGroup removeActionForKey:@"showPowerTimer"];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.3];
    [powerGroup runAction:fadeOut];
    
    SKNode *doubleFireGroup = [self childNodeWithName:@"doubleFireGroup"];
    [doubleFireGroup removeActionForKey:@"showDoubleFireTimer"];
    [doubleFireGroup runAction:fadeOut];
}






@end
