//
//  Hero.m
//  SpaceGame
//
//  Created by Никита Шарапов on 14.11.15.
//  Copyright © 2015 Никита Шарапов. All rights reserved.
//

#import "Hero.h"
#import "SKEmitterNode+Extensions.h"

@interface Hero()
@property (nonatomic, weak) UITouch *heroTouch;
@property (nonatomic) NSTimeInterval lastUpdatedTime;

@end

@implementation Hero

-(instancetype)init {
    if (self = [super init]) {
        //Hero
        SKSpriteNode *hero = [SKSpriteNode spriteNodeWithImageNamed:@"hero"];
        hero.name = @"hero";
        hero.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:@"hero"] size:hero.size];
        hero.physicsBody.dynamic = NO;
        //hero.size = CGSizeMake(45, 50);
        [self addChild:hero];

        
        
        //Fire
        SKEmitterNode *leftEngine = [SKEmitterNode nodeWithFile:@"fireBig.sks"];
        leftEngine.position = CGPointMake(-19, -57);
        [hero addChild:leftEngine];
        
        SKEmitterNode *rightEngine = [SKEmitterNode nodeWithFile:@"fireBig.sks"];
        rightEngine.position = CGPointMake(19, -57);
        [hero addChild:rightEngine];

    }
    return self;
}



@end

