//
//  Stars.m
//  SpaceGame
//
//  Created by Никита Шарапов on 04.11.15.
//  Copyright © 2015 Никита Шарапов. All rights reserved.
//

#import "Stars.h"

@implementation Stars

-(instancetype)init {
    if (self = [super init]) {
        __weak Stars *weakSelf = self;
        SKAction *update = [SKAction runBlock:^{
            if (arc4random_uniform(10) < 3) {
                [weakSelf createStars];
            }
        }];
        SKAction *delay = [SKAction waitForDuration:0.01];
        SKAction *updateLoop = [SKAction sequence:@[delay, update]];
        [self runAction:[SKAction repeatActionForever:updateLoop]];
        
    }
    return self;
}

-(void)createStars{
    CGFloat randomX = arc4random_uniform(self.scene.size.width);
    CGFloat maximumY = self.scene.size.height;
    CGPoint randomStart = CGPointMake(randomX, maximumY);
    
    SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"star"];
    star.position = randomStart;
    star.size = CGSizeMake(4, 10);
    star.alpha = 0.1 + (arc4random_uniform(10) / 10.0f);
    [self addChild:star];
    
    CGFloat destinationY = 0 - (self.scene.size.height - star.size.height);
    CGFloat duration = 0.1 + (arc4random_uniform(10) / 10.0f);
    SKAction *move = [SKAction moveByX:0 y:destinationY duration:duration];
    SKAction *remove = [SKAction removeFromParent];
    [star runAction:[SKAction sequence:@[move, remove]]];
    
}
@end
