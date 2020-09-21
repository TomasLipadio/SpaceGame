//
//  GameScene.m
//  SpaceGame
//
//  Created by Никита Шарапов on 05.11.15.
//  Copyright © 2015 Никита Шарапов. All rights reserved.
//

#import "Level1.h"
#import "Stars.h"
#import "SKEmitterNode+Extensions.h"
#import "HUDNode.h"
#import "GameOverNode.h"
#import "TitleScene.h"
#import "Hero.h"

#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define SK_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

@interface Level1()

@property (nonatomic, weak) UITouch *heroTouch;
@property (nonatomic) NSTimeInterval lastUpdatedTime;
@property (nonatomic) NSTimeInterval lastFireTime;
@property (nonatomic) CGFloat fireRate;
@property (nonatomic) CGFloat durationPath;

@property (nonatomic, strong) SKEmitterNode *enemyExplodeTemplate;
@property (nonatomic, strong) SKEmitterNode *heroExplodeTemplate;

@property (nonatomic) BOOL doubleFire;

@property (nonatomic, strong) SKAction *shootSound;
@property (nonatomic, strong) SKAction *heroExplodeSound;
@property (nonatomic, strong) SKAction *enemyExplodeSound;
@property (nonatomic, strong) SKAction *fontSound;

@property (nonatomic) BOOL gameOver;

@end


@implementation Level1


-(id)initWithSize:(CGSize)size{
    
    if (self = [super initWithSize:size]) {
        
        
        self.backgroundColor = [SKColor orangeColor];
        
        SKAction *act = [SKAction runBlock:^{
            SKSpriteNode  *foto = [SKSpriteNode spriteNodeWithImageNamed:@"IMG_4723"];
            foto.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
            foto.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            foto.alpha = 0;
            [self addChild:foto];
            
            SKAction *fade = [SKAction fadeAlphaTo:0 duration:0.5];
            SKAction *scale = [SKAction scaleTo:1 duration:2];
            SKAction *fadeR = [SKAction fadeAlphaTo:1 duration:0.5];
            SKAction *scaleR = [SKAction scaleTo:0 duration:2];
            SKAction *all1 = [SKAction group:@[fade, scale]];
            SKAction *all1R = [SKAction group:@[fadeR, scaleR]];
            
            SKAction *fse = [SKAction sequence:@[all1, all1R]];
            
            [foto runAction:fse];
        }];
        
        [self runAction:act];
        
        //Hero
        Hero *hero = [Hero node];
        hero.name = @"hero";
        hero.position = CGPointMake(self.size.width/2, 0 - (hero.frame.size.height + hero.frame.size.height/2));
        
        SKAction *into = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height/2) duration:0.8];
        
        SKAction *midle = [SKAction runBlock:^{
            SKEmitterNode *leftEngine = [SKEmitterNode nodeWithFile:@"fire.sks"];
            leftEngine.position = CGPointMake(-19, -57);
            [hero addChild:leftEngine];
            
            SKEmitterNode *rightEngine = [SKEmitterNode nodeWithFile:@"fire.sks"];
            rightEngine.position = CGPointMake(19, -57);
            [hero addChild:rightEngine];
            
            SKAction *remove = [SKAction removeFromParent];
            SKAction *ogon = [SKAction runBlock:^{
                [leftEngine runAction:remove];
                [rightEngine runAction:remove];
            }];
            SKAction *wait = [SKAction waitForDuration:0.5];
            SKAction *alls = [SKAction sequence:@[wait, ogon]];
            [hero runAction:alls];
            
        }];
        
        SKAction *fire = [SKAction group:@[into, midle]];
        SKAction *all = [SKAction sequence:@[fire]];
        
        [hero runAction:all];
        [self addChild:hero];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.heroTouch = [touches anyObject];
    
    if (_gameOver) {
        for (SKNode *node in [self children]) {
            [node removeFromParent];
        }
        TitleScene *scene = [TitleScene sceneWithSize:CGSizeMake(640, 1136)];
        [self.view presentScene:scene];
        
    }
    
}

-(void)update:(NSTimeInterval)currentTime
{
    
    
    if (self.lastUpdatedTime == 0) {
        self.lastUpdatedTime = currentTime;
        
    }
    
    
    if (self.heroTouch) {
        CGPoint touchLocation = [self.heroTouch locationInNode:self];
        touchLocation.y = touchLocation.y + 140; // чтобы герой был над пальцем
        [self moveHero:touchLocation];
        
        
    }
    
    self.lastUpdatedTime = currentTime;
}
-(void)moveHero:(CGPoint)point
{
    CGFloat heroSpeed = 120;
    SKNode *hero = [self childNodeWithName:@"hero"];
    CGFloat distanceLeft = sqrt(pow(hero.position.x - point.x, 2) + pow(hero.position.y - point.y, 2));
    if (distanceLeft > 4) {
        CGFloat distanceToTravel = self.size.height/heroSpeed;  // delta*speed расстояние перемещения можно и так без интервалов (self.size.height/heroSpeed)
        CGFloat angle = atan2(point.y - hero.position.y, point.x - hero.position.x);
        CGFloat yOffset = distanceToTravel * sin(angle);
        CGFloat xOffset = distanceToTravel * cos(angle);
        hero.position = CGPointMake(hero.position.x + xOffset, hero.position.y + yOffset);
        
        // повороты hero при движении вдоль x
         if (xOffset > 0) {
         //hero.zRotation = SK_DEGREES_TO_RADIANS(7) * -1;
         
         SKAction *returner = [SKAction rotateToAngle:SK_DEGREES_TO_RADIANS(8)*(-1) duration: 0.2];
         SKAction *duration = [SKAction waitForDuration:0.2];
         //SKAction *returnBack = [SKAction stop];
         SKAction *ret= [SKAction rotateToAngle:0 duration:0.05];
         SKAction *all = [SKAction sequence:@[returner, duration, ret]];
         [hero runAction:all];
         }
         else if (xOffset < 0){
         SKAction *returner1 = [SKAction rotateToAngle:SK_DEGREES_TO_RADIANS(8) duration: 0.2];
         SKAction *duration1 = [SKAction waitForDuration:0.2];
         SKAction *ret1 = [SKAction rotateToAngle:0 duration:0.05];
         SKAction *all1 = [SKAction sequence:@[returner1, duration1, ret1]];
         [hero runAction:all1];
         }
         
        
    }
}



@end
