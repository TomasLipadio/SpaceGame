//
//  GameScene.m
//  SpaceGame
//
//  Created by Никита Шарапов on 05.11.15.
//  Copyright © 2015 Никита Шарапов. All rights reserved.
//

#import "GameScene.h"
#import "Stars.h"
#import "SKEmitterNode+Extensions.h"
#import "HUDNode.h"
#import "GameOverNode.h"
#import "TitleScene.h"
#import "Level1.h"
#define SK_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define SK_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

static inline CGVector radiansToVector(CGFloat radians)
{
    CGVector vector;
    vector.dx = cosf(radians);
    vector.dy = sinf(radians);
    return vector;
}

@interface GameScene()

@property (nonatomic, weak) UITouch *heroTouch;
@property (nonatomic) NSTimeInterval lastUpdatedTime;
@property (nonatomic) NSTimeInterval lastFireTime;

@property (nonatomic) CGFloat fireRate;
@property (nonatomic) CGFloat durationPath;
@property (nonatomic) CGFloat SHOOT_SPEED;

@property (nonatomic) int a;
@property (nonatomic) int p;
@property (nonatomic) int bossPath;

// Health
@property (nonatomic) int CnstPartHP;

@property (nonatomic) int HeroHP;
@property (nonatomic) int ShieldHP;
@property (nonatomic) CGFloat partHP;
@property (nonatomic) CGFloat partHP2; // HP для partsBoss треугольники
@property (nonatomic) CGFloat partHP3;
@property (nonatomic) CGFloat partHP4;
@property (nonatomic) CGFloat partHP1;

@property (nonatomic) int bossHP;

//
@property (nonatomic) int kL;        // настоящий костыль, чтобы после исчезновения gunLeft исчезли и shoot этой пушки
@property (nonatomic) int kR;        // настоящий костыль, чтобы после исчезновения gunRight исчезли и shoot этой пушки

@property (nonatomic, strong) SKEmitterNode *enemyExplodeTemplate;
@property (nonatomic, strong) SKEmitterNode *heroExplodeTemplate;
@property (nonatomic, strong) SKEmitterNode *fire;

@property (nonatomic) BOOL doubleFire;
@property (nonatomic) BOOL heroShield;
@property (nonatomic) BOOL minusHP;
@property (nonatomic) BOOL bossIt;

@property (nonatomic) BOOL gunDown;
@property (nonatomic) BOOL partsDown;
@property (nonatomic) BOOL leftGunDown;
@property (nonatomic) BOOL rightGunDown;
@property (nonatomic) BOOL partDown;
@property (nonatomic) BOOL partDown1;
@property (nonatomic) BOOL partDown2;
@property (nonatomic) BOOL partDown3;
@property (nonatomic) BOOL partDown4;
@property (nonatomic) BOOL bossDown;
@property (nonatomic) BOOL enemyDroping;


@property (nonatomic) BOOL heroShieldPAD;



@property (nonatomic, strong) SKAction *shootSound;
@property (nonatomic, strong) SKAction *heroExplodeSound;
@property (nonatomic, strong) SKAction *enemyExplodeSound;
@property (nonatomic, strong) SKAction *fontSound;

@property (nonatomic) BOOL gameOver;

@property (nonatomic) SKShapeNode *layer;

@end


@implementation GameScene


-(id)initWithSize:(CGSize)size{
    
    if (self = [super initWithSize:size]) {
    
        _layer = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(640, 1136)];
        
        _minusHP = YES;  // индикатор HP, YES стоит для того чтобы первый раз показывал без столкновений полные HP
        
        _heroShieldPAD = NO; // выпал ли щит на поле
        
        self.a = 0;
        _HeroHP = 0;
        _ShieldHP = 0;
        _partHP = 0;
        _partHP2 = 0;
        _partHP3 = 0;
        _partHP4 = 0;
        _partHP1 = 0;
        
        _enemyDroping = YES; //дроп всех врагов
        self.SHOOT_SPEED = 300; // скорость выстрела босса
        self.CnstPartHP = 6; // HP для частей Boss
        self.backgroundColor = [SKColor blackColor];
        
        
        SKSpriteNode *back = [SKSpriteNode spriteNodeWithImageNamed:@"background.jpg"];
        back.name = @"background";
        back.position = CGPointMake(self.size.width/2, self.size.height/2);
        back.zPosition = -10;
        [self addChild:back];
        
        
        
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        
        //background stars
        Stars *starsField = [Stars node];
        [self addChild:starsField];
        
        //Hero
        SKSpriteNode *hero = [SKSpriteNode spriteNodeWithImageNamed:@"hero"];
        hero.position = CGPointMake(size.width/2, size.height/2);
        hero.zPosition = 2;
        
        //hero.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:@"hero"] size:hero.size];
        //hero.physicsBody.dynamic = NO;
        //hero.size = CGSizeMake(45, 50);
        hero.name = @"hero";
        [self addChild:hero];
        
        //Fire
        SKEmitterNode *leftEngine = [SKEmitterNode nodeWithFile:@"fireBig.sks"];
        leftEngine.position = CGPointMake(-19, -57);
        [hero addChild:leftEngine];
        
        SKEmitterNode *rightEngine = [SKEmitterNode nodeWithFile:@"fireBig.sks"];
        rightEngine.position = CGPointMake(19, -57);
        [hero addChild:rightEngine];
        
        //Fire rate
        self.fireRate = 0.5;
        
        //Double Fire
        self.doubleFire = NO;
        
        //Hero Shield
        _heroShield = NO;
        
        //Duration path
        self.durationPath = 7;
        
        //Exploision Templates
        
        self.enemyExplodeTemplate = [SKEmitterNode nodeWithFile:@"enemyExplode.sks"];
        self.heroExplodeTemplate = [SKEmitterNode nodeWithFile:@"heroExplode.sks"];
        self.fire = [SKEmitterNode nodeWithFile:@"fire.sks"];
        
        
        // Sound Initialization
        self.shootSound = [SKAction playSoundFileNamed:@"shot.mp3" waitForCompletion:NO];
        self.enemyExplodeSound = [SKAction playSoundFileNamed:@"explosion.mp3" waitForCompletion:NO];
        self.heroExplodeSound = [SKAction playSoundFileNamed:@"explosionbig.mp3" waitForCompletion:NO];
        
        // HUD node
        HUDNode *hudNode = [HUDNode node];
        hudNode.name = @"hud";
        hudNode.zPosition = -8;
        hudNode.position = CGPointMake(self.size.width/2, self.size.height/2);
        hudNode.alpha = 0.4;
        [self addChild:hudNode];
        
        [hudNode layoutControls];
        [hudNode startGame];
        
        self.gameOver = NO;

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
        //Level1 *scene = [Level1 sceneWithSize:CGSizeMake(640, 1136)];
        [self.view presentScene:scene];
    }
    
}

-(void)update:(NSTimeInterval)currentTime
{
    HUDNode *hud = (HUDNode *)[self childNodeWithName:@"hud"];
    // drop boss
    

    if (hud.score >= 3000) { // появление при достижении очков
        self.a++;

    }
    
    if (self.a == 1) {
        
        _bossIt = YES;          // появляение босса
        
        [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *enemy, BOOL *stop) {
            // убрать бонусы
            _doubleFire = NO;
            self.fireRate = 0.5;
            [enemy removeFromParent];

        }];
        [self dropBoss];

        _enemyDroping = NO;
    }
 
    if (self.lastUpdatedTime == 0) {
        self.lastUpdatedTime = currentTime;
        
    }
    
    NSTimeInterval delta = currentTime - self.lastUpdatedTime; // время перемещения duration
    
   if (self.heroTouch) {
        CGPoint touchLocation = [self.heroTouch locationInNode:self];
        touchLocation.y = touchLocation.y + 140; // чтобы герой был над пальцем
        [self moveHero:touchLocation byTimeDelta:delta];
        
        // уничтожение и появления выстрелов у boosGun
        if (self.kL == 0) { // для левого Gun условия
            
            SKNode *boss = [self childNodeWithName:@"boss"];
            SKNode *gunLeft = [boss childNodeWithName:@"gunLeft"];
            SKNode *shootingL = [gunLeft childNodeWithName:@"shootLeft"];
            
            [shootingL removeFromParent];

            if (currentTime - self.lastFireTime > self.fireRate) {
                if (_bossIt){
                [self bossShootLeft];
                }
            
           }
        }
        if (self.kR == 0) { // для правого Gun условие
            
            SKNode *boss = [self childNodeWithName:@"boss"];
            SKNode *gunRight = [boss childNodeWithName:@"gunRight"];
            SKNode *shootingR = [gunRight childNodeWithName:@"shootRight"];
            
            [shootingR removeFromParent];

            if (currentTime - self.lastFireTime > self.fireRate) {
                if (_bossIt){
                [self bossShootRight];
                }
            }
        }
       [self moveHero:touchLocation byTimeDelta:delta];
       
       if (currentTime - self.lastFireTime > self.fireRate) {
           [self normalShoot];
           if (_doubleFire) {
               [self doubleShoot];
           }
           self.lastFireTime = currentTime;
       }
   }
   
    
        if (_partDown == YES && _partDown1 == YES && _partDown2 == YES && _partDown3 == YES && _partDown4 == YES) {
            _partsDown = YES;
        }
        if (_leftGunDown == YES && _rightGunDown == YES) {
            _gunDown = YES;
        }

    
    
    if (_enemyDroping) {
        NSInteger dropGameObjectsFrequency = 20;
        if (arc4random_uniform(1000) <= dropGameObjectsFrequency) {
            [self dropGameObjects];
        } 
    }
    [self checkForCollisions];
    [self checkForCollisionBoss];

    self.lastUpdatedTime = currentTime;
}
-(void)checkForCollisionBoss
{
    SKNode *hero = [self childNodeWithName:@"hero"];
    SKNode *shield = [hero childNodeWithName:@"heroShield"];
    
//    SKAction *drojU = [SKAction moveTo:CGPointMake(hero.position.x, hero.position.y+1) duration:0.1];
//    SKAction *drojD = [SKAction moveTo:CGPointMake(hero.position.x, hero.position.y-1) duration:0.1];
//    SKAction *durationDroj = [SKAction waitForDuration:0.1];
//    SKAction *droj = [SKAction sequence:@[drojU, durationDroj, drojD, durationDroj]];
//    [hero runAction:droj];

    
    [self enumerateChildNodesWithName:@"fire" usingBlock:^(SKNode *fire, BOOL *stop) {
        
        [self enumerateChildNodesWithName:@"shootRight" usingBlock:^(SKNode *shootRight, BOOL *stop) {
            
            if ([shield intersectsNode:shootRight]) {
                [shield removeFromParent];
                [shootRight removeFromParent];
            }
            
            if ([hero intersectsNode:shootRight]) {

                if  (_heroShield){
                    [hero addChild:shield];
                    _ShieldHP ++;
                    if (_ShieldHP >=2){
                        _heroShield = NO;
                        [shield removeFromParent];
                        _heroShieldPAD = NO;
                    }
                }
                else {
                    [shootRight removeFromParent];
                    _HeroHP ++;
                    _minusHP = YES;

                    if (_HeroHP >= 4){
                        self.heroTouch = nil;
                        [hero removeAllChildren];
                        [hero removeFromParent];
                        [shootRight removeFromParent];
                        [self endGame];
                    }
                }
            }
            
            if ([fire intersectsNode:shootRight]) {
                [fire removeFromParent];
                [shootRight removeFromParent];
                }

        }];
        
        [self enumerateChildNodesWithName:@"shootLeft" usingBlock:^(SKNode *shootLeft, BOOL *stop) {
            if ([hero intersectsNode:shootLeft]) {
                if (_heroShield){
                    _ShieldHP ++;
                    if (_ShieldHP >= 1) {
                        _heroShield = NO;
                        [shield removeFromParent];
                        _heroShieldPAD = NO;
                    }
                }
                else {
                    [shootLeft removeFromParent];
                    _HeroHP++;
                    _minusHP = YES;

                    if (_HeroHP >= 4){
                        self.heroTouch = nil;
                        [hero removeAllChildren];
                        [hero removeFromParent];
                        [shootLeft removeFromParent];
                        [self endGame];
                    }
                }
            }
    
            if ([fire intersectsNode:shootLeft]) {
                [fire removeFromParent];
                [shootLeft removeFromParent];
            }
        }];
        
            }];

}



-(void)checkForCollisions
{
    SKNode *hero = [self childNodeWithName:@"hero"];
    SKNode *boss = [self childNodeWithName:@"boss"];
    SKNode *gunLeft = [boss childNodeWithName:@"gunLeft"];
    SKNode *gunRight = [boss childNodeWithName:@"gunRight"];
    
    
    
    // Boss Parts
    SKNode *part = [boss childNodeWithName:@"bossPart"];
    SKNode *part1 = [boss childNodeWithName:@"bossPart1"];
    SKNode *part2 = [boss childNodeWithName:@"bossPart2"];
    SKNode *part3 = [boss childNodeWithName:@"bossPart3"];
    SKNode *part4 = [boss childNodeWithName:@"bossPart4"];
    
    [self enumerateChildNodesWithName:@"power" usingBlock:^(SKNode *power, BOOL *stop) {
        if ([hero intersectsNode:power]) {
            
            HUDNode *hud = (HUDNode *)[self childNodeWithName:@"hud"];
            [hud showPowerTimer:5];
            
            [power removeFromParent];
            self.fireRate = 0.1;
            
            SKAction *powerDown = [SKAction runBlock:^{
                self.fireRate = 0.5;
            }];
            SKAction *wait = [SKAction waitForDuration:5];
            SKAction *waitAndPowerDown = [SKAction sequence:@[wait, powerDown]];
            [hero removeActionForKey:@"waitAndPowerDown"];
            [hero runAction:waitAndPowerDown withKey:@"waitAndPowerDown"];
            
        }
    }];
    
    [self enumerateChildNodesWithName:@"doublefire" usingBlock:^(SKNode *doublefire, BOOL *stop) {
        if ([hero intersectsNode:doublefire]) {
            
            HUDNode *hud = (HUDNode *)[self childNodeWithName:@"hud"];
            [hud showDoubleFireTimer:7];
            
            [doublefire removeFromParent];
            self.doubleFire = YES;
            
            SKAction *removeDoubleFire = [SKAction runBlock:^{
                self.doubleFire = NO;
            }];
            SKAction *wait = [SKAction waitForDuration:7];
            SKAction *waitAndRemoveDoubleFire = [SKAction sequence:@[wait, removeDoubleFire]];
            [hero removeActionForKey:@"waitAndRemoveDoubleFire"];
            [hero runAction:waitAndRemoveDoubleFire withKey:@"waitAndRemoveDoubleFire"];
            
        }
    }];
    
    [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *enemy, BOOL *stop) {
        
        if ([hero intersectsNode:enemy]) {
            // cтолкновение с любым enemy по имени
            SKNode *hero = [self childNodeWithName:@"hero"];
            SKNode *shield = [hero childNodeWithName:@"heroShield"];
            [enemy removeFromParent];
            if  (_heroShield){
                _ShieldHP ++;
                if (_ShieldHP >=1){
                    _heroShield = NO;
                    for (int i=0; i<_ShieldHP; i++) {
                        [shield removeFromParent];
                        _heroShieldPAD = NO;
                    }
                    _ShieldHP = 0;
                }
            }else {
                _HeroHP ++;
                _minusHP = YES; // чтобы индикатор подгружался один раз
                if (_HeroHP >= 4){
                   
                    self.heroTouch = nil;
                    [hero removeAllChildren]; // убрать баг выстрелов после смерти
                    [hero removeFromParent];
                    
                
                    
                    SKEmitterNode *explosion = [self.heroExplodeTemplate copy];
                    explosion.position = hero.position;
                    [explosion dieInDuration:0.3];
                    [self addChild:explosion];
                    
                    [self runAction:self.heroExplodeSound];
                    
                    [self endGame];
                    

                }
            }
            
            

        }
        
        
        
        [self enumerateChildNodesWithName:@"fire" usingBlock:^(SKNode *fire, BOOL *stop) {
            if ([fire intersectsNode:enemy]) {
                [fire removeFromParent];
                [enemy removeFromParent];
                
                [self runAction:self.enemyExplodeSound];
                
                SKEmitterNode *explosion = [self.enemyExplodeTemplate copy];
                explosion.position = enemy.position;
                [explosion dieInDuration:0.1];
                [self addChild:explosion];
                
                HUDNode *hud = (HUDNode *)[self childNodeWithName:@"hud"];
                NSInteger score = 2 * hud.elapsedTime;  //множитель очков
                
                [hud addPoints:score];
                
                *stop = YES;
            }
        }];
    }];
    
        [self enumerateChildNodesWithName:@"fire" usingBlock:^(SKNode *fire, BOOL *stop) {
            if ([gunLeft intersectsNode:fire]) {
                [gunLeft removeFromParent];
                [fire removeFromParent];
                _leftGunDown = YES;
                self.kL++;
                *stop = YES;

                
            }
            
            if ([gunRight intersectsNode:fire]) {
                [gunRight removeFromParent];
                [fire removeFromParent];
                _rightGunDown = YES;
                self.kR++;
                *stop = YES;

                
            }
            
            if ([part intersectsNode:fire]) {
                _partHP ++;
                [fire removeFromParent];
                if (_partHP >= _CnstPartHP) {
                [fire removeFromParent];
                [part removeFromParent];
                    _partDown = YES;
                    _partHP = 0;
                    *stop = YES;

                }
            }
            
            if ([part1 intersectsNode:fire]) {
                _partHP1 ++;
                [fire removeFromParent];
                if (_partHP1 >= _CnstPartHP) {
                    [fire removeFromParent];
                    [part1 removeFromParent];
                    _partDown1 = YES;
                    *stop = YES;

                }
            }
            
            if ([part2 intersectsNode:fire]) {
                _partHP2 ++;
                [fire removeFromParent];
                if (_partHP2 >= _CnstPartHP) {
                    [fire removeFromParent];
                    [part2 removeFromParent];
                    _partDown2 = YES;
                    *stop = YES;

                }
            }
            if ([part3 intersectsNode:fire]) {
                _partHP3 ++;
                [fire removeFromParent];
                if (_partHP3 >= _CnstPartHP) {
                    [fire removeFromParent];
                    [part3 removeFromParent];
                    _partDown3 = YES;
                    *stop = YES;
                }
            }
            if ([part4 intersectsNode:fire]) {
                _partHP4 ++;
                [fire removeFromParent];
                if (_partHP4 >= _CnstPartHP) {
                    [fire removeFromParent];
                    [part4 removeFromParent];
                    _partDown4 = YES;
                    *stop = YES;
                }
            }
            
            
            if (_gunDown == YES && _partsDown == YES) {
                if ([boss intersectsNode:fire]) {
                    [fire removeFromParent];
                    _bossHP ++;
                    *stop = YES;

                    if (_bossHP >= _CnstPartHP) {
                        [fire removeFromParent];
                        [boss removeFromParent];
                        HUDNode *hud = (HUDNode *)[self childNodeWithName:@"hud"];
                        NSInteger score = 1000;  //костыль для очков босса
                       
                        [hud addPoints:score];
                        
                        self.heroTouch = nil;
                        _bossIt = NO;
                        *stop = YES;

                        // убрать бонусы
                        _doubleFire = NO;
                        self.fireRate = 0.5;

                        SKAction *moveHeroFrom = [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height + 3 * hero.frame.size.height) duration:1];
                        SKAction *moveHeroFromExplosion = [SKAction runBlock:^{
                            SKEmitterNode *explosion = [self.fire copy];
                            [explosion dieInDuration:1];
                            [hero addChild:explosion];
                        }];
                        SKAction *nextLevel = [SKAction runBlock:^{
                            Level1 *scene = [Level1 sceneWithSize:CGSizeMake(640, 1136)];
                            //SKTransition *transition = [SKTransition fadeWithDuration:2.0];
                            //[self.view presentScene:scene transition:transition];
                            [self.view presentScene:scene];
                        }];
                        SKAction *duration = [SKAction waitForDuration:1];
                        SKAction *moveFrom = [SKAction group:@[moveHeroFrom, moveHeroFromExplosion]];
                        SKAction *allFrom = [SKAction sequence:@[moveFrom, duration, nextLevel]];
                        [hero runAction:allFrom];
                        
                    }
                }
            }

        }];
    
    [self enumerateChildNodesWithName:@"Shield" usingBlock:^(SKNode *Shield, BOOL *stop) {
        if ([hero intersectsNode:Shield]) {
            [Shield removeFromParent];
            if (_heroShield == YES) {
                [Shield removeFromParent];
            }
            
            _heroShield = YES;
            [self addShield];
        }
    }];
  
}

-(void)addShield {
    SKNode *hero = [self childNodeWithName:@"hero"];
    SKSpriteNode *heroShield = [SKSpriteNode spriteNodeWithImageNamed:@"heroShield.png"];
    
    heroShield.name = @"heroShield";
    heroShield.zPosition = 3;
    
    [hero addChild:heroShield];
    
}

-(void)endGame{
    _gameOver = YES;
    
    GameOverNode *gameOverNode = [GameOverNode node];
    gameOverNode.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:gameOverNode];
    
    HUDNode *hud = (HUDNode *)[self childNodeWithName:@"hud"];
    [hud endGame];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *highScore = [defaults valueForKey:@"highScore"];
    if (highScore.integerValue < hud.score) {
        [defaults setValue:@(hud.score) forKey:@"highScore"];
    }

}

-(void)moveHero:(CGPoint)point byTimeDelta:(NSTimeInterval)timeDelta
{
    CGFloat heroSpeed = 520;
    SKNode *hero = [self childNodeWithName:@"hero"];
    CGFloat distanceLeft = sqrt(pow(hero.position.x - point.x, 2) + pow(hero.position.y - point.y, 2));
    if (distanceLeft > 4) {
        CGFloat distanceToTravel = heroSpeed * timeDelta;  // delta*speed расстояние перемещения можно и так без интервалов (self.size.height/heroSpeed)
        CGFloat angle = atan2(point.y - hero.position.y, point.x - hero.position.x);
        CGFloat yOffset = distanceToTravel * sin(angle);
        CGFloat xOffset = distanceToTravel * cos(angle);
        hero.position = CGPointMake(hero.position.x + xOffset, hero.position.y + yOffset);
        
      // повороты hero при движении вдоль x
       /* if (xOffset > 0) {
            //hero.zRotation = SK_DEGREES_TO_RADIANS(7) * -1;
            
            SKAction *returner = [SKAction rotateToAngle:SK_DEGREES_TO_RADIANS(15)*(-1) duration: 0.2];
            SKAction *duration = [SKAction waitForDuration:0.2];
            //SKAction *returnBack = [SKAction stop];
            SKAction *ret= [SKAction rotateToAngle:0 duration:0.5];
            SKAction *all = [SKAction sequence:@[returner, duration, ret]];
            [hero runAction:all];
        }
        else if (xOffset < 0){
            SKAction *returner1 = [SKAction rotateToAngle:SK_DEGREES_TO_RADIANS(15) duration: 0.2];
            SKAction *duration1 = [SKAction waitForDuration:0.2];
            SKAction *ret1 = [SKAction rotateToAngle:0 duration:0.5];
            SKAction *all1 = [SKAction sequence:@[returner1, duration1, ret1]];
            [hero runAction:all1];
        }
        */
        
    }
}

-(void)normalShoot
{
    if (_doubleFire) {
    }
    else{
    SKNode *hero = [self childNodeWithName:@"hero"];
    
    SKSpriteNode *fire = [SKSpriteNode spriteNodeWithImageNamed:@"fire"];
    fire.name = @"fire";
    fire.size = CGSizeMake(20, 26);
        fire.zPosition = 2;
    fire.position = CGPointMake(hero.position.x, hero.position.y + hero.frame.size.height/2);
    
    [self addChild:fire];
    
    SKAction *move = [SKAction moveByX:0 y:self.size.height + fire.size.height duration:0.5];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *moveAndRemove = [SKAction sequence:@[move, remove]];
    [fire runAction:moveAndRemove];
    }
    [self runAction:self.shootSound];
    
}

// левый ган
-(void)bossShootLeft{
    SKNode *boss = [self childNodeWithName:@"boss"];
    SKNode *gunL = [boss childNodeWithName:@"gunLeft"];
    
    // вычисляет позицию, чтобы добавить на self
    CGFloat gunLPosX = boss.position.x + gunL.position.x;
    CGFloat gunLPosY = boss.position.y + gunL.position.y;
    
    // вычисляет угол поворота пушки, под которым идет выстрел
    CGVector rotationVectorL = radiansToVector(gunL.zRotation);
    
    SKSpriteNode *shootL = [SKSpriteNode spriteNodeWithImageNamed:@"halo.png"];
    shootL.zPosition = 1.5;
    shootL.size = CGSizeMake(20, 20);
    
    shootL.position = CGPointMake(gunLPosX, gunLPosY); // чтобы при прокрутке позиция выстрела изменялась
    shootL.name = @"shootLeft";
    
    shootL.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:shootL.size.height/2];
    shootL.physicsBody.velocity = CGVectorMake(rotationVectorL.dx * self.SHOOT_SPEED,
                                               rotationVectorL.dy * self.SHOOT_SPEED);
    shootL.physicsBody.restitution = 1.0;
    shootL.physicsBody.linearDamping = 0.0;
    shootL.physicsBody.friction = 0.0;
    [self addChild:shootL];
    
    SKAction *duration = [SKAction waitForDuration:3];
    SKAction *remove = [SKAction runBlock:^{
        [shootL removeFromParent];
    } ];
    SKAction *removeAll = [SKAction sequence:@[duration, remove]];
    
    [self runAction:removeAll];

  
}

// правый ган
-(void)bossShootRight{
    SKNode *boss = [self childNodeWithName:@"boss"];
    SKNode *gunR = [boss childNodeWithName:@"gunRight"];
    
    CGFloat gunRPosX = boss.position.x + gunR.position.x;
    CGFloat gunRPosY = boss.position.y + gunR.position.y;
    
    CGVector rotationVectorR = radiansToVector(gunR.zRotation);
    
    SKSpriteNode *shootR = [SKSpriteNode spriteNodeWithImageNamed:@"halo.png"];
    shootR.zPosition = 1.5;
    shootR.size = CGSizeMake(20, 20);
    
    shootR.position = CGPointMake(gunRPosX, gunRPosY); // чтобы при прокрутке позиция выстрела изменялась
    shootR.name = @"shootRight";
    
    shootR.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:shootR.size.height/2];
    shootR.physicsBody.velocity = CGVectorMake(rotationVectorR.dx * self.SHOOT_SPEED,
                                               rotationVectorR.dy * self.SHOOT_SPEED );
    shootR.physicsBody.restitution = 1.0;
    shootR.physicsBody.linearDamping = 0.0;
    shootR.physicsBody.friction = 0.0;
    
    [self addChild:shootR];
    
    SKAction *duration = [SKAction waitForDuration:3];
    SKAction *remove = [SKAction runBlock:^{
        [shootR removeFromParent];
    } ];
    SKAction *removeAll = [SKAction sequence:@[duration, remove]];
    
    [self runAction:removeAll];
    
}



-(void)doubleShoot
{
    SKNode *hero = [self childNodeWithName:@"hero"];
    
    SKSpriteNode *fire = [SKSpriteNode spriteNodeWithImageNamed:@"fire"];
    fire.name = @"fire";
    fire.zPosition = 3;
    fire.size = CGSizeMake(20, 26);
    fire.position = CGPointMake(hero.position.x - 40, hero.position.y + hero.frame.size.height/2-35);
    [self addChild:fire];
    
    SKSpriteNode *fire1 = [SKSpriteNode spriteNodeWithImageNamed:@"fire"];
    fire1.name = @"fire";
    fire1.zPosition = 3;
    fire1.size = CGSizeMake(20, 26);
    fire1.position = CGPointMake(hero.position.x + 40, hero.position.y + hero.frame.size.height/2-35);
    [self addChild:fire1];
    
    SKAction *move = [SKAction moveByX:0 y:self.size.height + fire.size.height duration:0.5];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *moveAndRemove = [SKAction sequence:@[move, remove]];
    
    SKAction *move1 = [SKAction moveByX:0 y:self.size.height + fire1.size.height duration:0.5];
    SKAction *remove1 = [SKAction removeFromParent];
    SKAction *moveAndRemove1 = [SKAction sequence:@[move1, remove1]];
    
    [fire runAction:moveAndRemove];
    [fire1 runAction:moveAndRemove1];
    [self runAction:self.shootSound];

}

-(void)dropGameObjects
{
    u_int32_t dice = arc4random_uniform(100);
    if (dice < 3) {
        [self dropPower];
    }
    if ( dice < 9 && dice > 3) {
        [self dropDoublePower];
    }
    if (dice < 15) {
        [self dropEnemyType1];
    }
    if (_heroShieldPAD == NO) {
        if (dice < 19 && dice > 9) {
            [self dropShield];
            _heroShieldPAD = YES;
        }
    }
    if (dice < 25) {
        [self dropEnemyType2];
    }
    else {
        [self dropUFO];
    }
}



-(void)dropBoss{
    
//Boss Osnova
    SKSpriteNode *bossOsnova = [SKSpriteNode spriteNodeWithImageNamed:@"bossOsnova.png"];
    
    bossOsnova.anchorPoint = CGPointMake(0, 0);
    bossOsnova.zPosition = 1;
    bossOsnova.position = CGPointMake(0, self.size.height + bossOsnova.size.height);
    //bossOsnova.position = CGPointMake(self.size.width/4, (self.size.height/3)*2);
    bossOsnova.size = CGSizeMake(bossOsnova.size.width, bossOsnova.size.height);
    bossOsnova.name = @"boss";
    
//Boss Gun
    CGFloat gunSize = 50;
    CGFloat gunAngle = 60; // для вращения
    CGFloat rotationRate = 2; // для вращения
    CGFloat moveRate = 1;
    
    SKSpriteNode *bossGunLeft = [SKSpriteNode spriteNodeWithImageNamed:@"bossGun.png"];
    SKSpriteNode *bossGunRight = [SKSpriteNode spriteNodeWithImageNamed:@"bossGun.png"];


    bossGunLeft.name = @"gunLeft";
    bossGunRight.name = @"gunRight";
    
    CGVector gunVectorToRight= CGVectorMake(100, 0);
    CGVector gunVectorToLeft= CGVectorMake(-100, 0);
    
    bossGunLeft.size = CGSizeMake(gunSize, gunSize);
    bossGunLeft.position = CGPointMake(128/2, 179/2);
    bossGunLeft.zPosition = 2;
    
    bossGunLeft.zRotation = SK_DEGREES_TO_RADIANS(-60);
    bossGunRight.zRotation = SK_DEGREES_TO_RADIANS(-60);

    
    bossGunRight.position = CGPointMake(bossOsnova.size.width - 128/2, 179/2);
    bossGunRight.size = CGSizeMake(gunSize, gunSize);
    bossGunRight.zPosition = 2;
    
// вращение Gun
    SKAction *rotateGunLeft = [SKAction rotateByAngle:SK_DEGREES_TO_RADIANS(gunAngle) duration:rotationRate];
    SKAction *rotateGunRight = [SKAction rotateByAngle:SK_DEGREES_TO_RADIANS(-gunAngle) duration:rotationRate];
    SKAction *rotate = [SKAction sequence:@[rotateGunRight, rotateGunLeft]];
    SKAction *rotateAll = [SKAction repeatActionForever:rotate];
    
    [bossGunLeft runAction:rotateAll];
    [bossGunRight runAction:rotateAll];
    
// движение Gun
    SKAction *moveRight = [SKAction moveBy:gunVectorToRight duration:moveRate];
    SKAction *moveLeft = [SKAction moveBy:gunVectorToLeft duration:moveRate];
    SKAction *gunDuration = [SKAction waitForDuration:moveRate * 2]; // задержка, чтобы не пересеклись один движется другой стоит
    
    SKAction *moveGunLeft = [SKAction sequence:@[moveRight, moveLeft, gunDuration]];
    SKAction *moveGunLeftForEver = [SKAction repeatActionForever:moveGunLeft];
    
    SKAction *moveGunRight = [SKAction sequence:@[gunDuration, moveLeft, moveRight]];
    SKAction *moveGunRightForEver = [SKAction repeatActionForever:moveGunRight];
    
    [bossGunRight runAction:moveGunRightForEver];
    [bossGunLeft runAction:moveGunLeftForEver];
    
    //Boss part
    SKSpriteNode *bossPart = [SKSpriteNode spriteNodeWithImageNamed:@"bossPart"];
    SKSpriteNode *bossPart1 = [SKSpriteNode spriteNodeWithImageNamed:@"bossPart"];
    SKSpriteNode *bossPart2 = [SKSpriteNode spriteNodeWithImageNamed:@"bossPart"];
    SKSpriteNode *bossPart3 = [SKSpriteNode spriteNodeWithImageNamed:@"bossPart"];
    SKSpriteNode *bossPart4 = [SKSpriteNode spriteNodeWithImageNamed:@"bossPart"];
    
    CGFloat bossPartSize = 60;
    
    bossPart.anchorPoint = CGPointMake(0.5, 0);
    bossPart.position = CGPointMake(bossOsnova.size.width/3, 0);
    bossPart.zRotation = SK_DEGREES_TO_RADIANS(180);
    bossPart.name = @"bossPart";
    bossPart.size = CGSizeMake(bossPartSize, bossPartSize);
    
    bossPart1.anchorPoint = CGPointMake(0.5, 1);
    bossPart1.position = CGPointMake(bossOsnova.size.width/5, 0);
    bossPart1.name = @"bossPart1";
    bossPart1.size = CGSizeMake(bossPartSize, bossPartSize);
    
    bossPart2.anchorPoint = CGPointMake(0.5, 1);
    bossPart2.position = CGPointMake(bossOsnova.size.width/2, 0);
    bossPart2.name = @"bossPart2";
    bossPart2.size = CGSizeMake(bossPartSize, bossPartSize);
    
    bossPart3.anchorPoint = CGPointMake(0.5, 1);
    bossPart3.position = CGPointMake(bossOsnova.size.width - bossOsnova.size.width/5, 0);
    bossPart3.name = @"bossPart3";
    bossPart3.size = CGSizeMake(bossPartSize, bossPartSize);
    
    bossPart4.anchorPoint = CGPointMake(0.5, 0);
    bossPart4.position = CGPointMake(bossOsnova.size.width-bossOsnova.size.width/3, 0);
    bossPart4.zRotation = SK_DEGREES_TO_RADIANS(180);
    bossPart4.name = @"bossPart4";
    bossPart4.size = CGSizeMake(bossPartSize, bossPartSize);
    
// шевеление треугольников
    SKAction *shapeIn = [SKAction scaleBy:0.9 duration:0.3];
    SKAction *shapeIn1 = [SKAction scaleBy:1.1 duration:0.3];
    SKAction *shapeOut = [SKAction scaleTo:1 duration:0.3];
    SKAction *shape = [SKAction sequence:@[shapeIn, shapeOut]];
    SKAction *shape1 = [SKAction sequence:@[shapeIn1, shapeOut]];
    SKAction *repeat1 = [SKAction repeatActionForever:shape1];
    SKAction *repeat = [SKAction repeatActionForever:shape];
    
    [bossPart1 runAction:repeat];
    [bossPart2 runAction:repeat1];
    [bossPart4 runAction:repeat1];
    [bossPart3 runAction:repeat];
    [bossPart runAction:repeat1];
    
    
// добавление объектов к основе
    [self addChild:bossOsnova]; // сама основа

    
    [bossOsnova addChild:bossGunLeft];
    [bossOsnova addChild:bossGunRight];
    
    
    [bossOsnova addChild:bossPart1]; // здесь по порядку появления, чтобы пересечения были удачные
    [bossOsnova addChild:bossPart2];
    [bossOsnova addChild:bossPart3];
    [bossOsnova addChild:bossPart4];
    [bossOsnova addChild:bossPart];
    
    SKAction *position1 = [SKAction moveTo:CGPointMake(self.size.width/2, (self.size.height/3)*2) duration:7];
    [bossOsnova runAction:position1];
    
    SKAction *duration = [SKAction waitForDuration:4];
    SKAction *position2 = [SKAction moveTo:CGPointMake(bossOsnova.size.width * 0.1, (self.size.height/4)*3) duration:4];
    SKAction *position3 = [SKAction moveTo:CGPointMake(self.size.width - (bossOsnova.size.width + (bossOsnova.size.width * 0.1)), (self.size.height/4)*3) duration:4];
    
    SKAction *positionLeft = [SKAction group:@[position3, duration]];
    SKAction *positionRight = [SKAction group:@[position2, duration]];
    SKAction *position2all = [SKAction sequence:@[positionLeft, positionRight]];
    
    SKAction *positionForRever = [SKAction repeatActionForever:position2all];
    
    [bossOsnova runAction:positionForRever];
    
}

-(void)dropPower {
    CGFloat powerSize = 60;
    CGFloat startX = arc4random_uniform(self.size.width - 160) + 30;
    CGFloat startY = self.size.height + powerSize;
    CGFloat EndY = 0 - powerSize;
    
    SKSpriteNode *power = [SKSpriteNode spriteNodeWithImageNamed:@"power0"];
    power.name = @"power";
    power.size = CGSizeMake(powerSize, powerSize * 1.083);
    power.position = CGPointMake(startX, startY);
    [self addChild:power];
    
    NSArray *texture = @[[SKTexture textureWithImageNamed:@"power0" ],
                         [SKTexture textureWithImageNamed:@"power1"]];
    
    SKAction *powerAnimation = [SKAction animateWithTextures:texture timePerFrame:0.5];
    SKAction *powerAnimationRepeat = [SKAction repeatActionForever:powerAnimation];
    [power runAction:powerAnimationRepeat];
    
    SKAction *move = [SKAction moveTo:CGPointMake(startX, EndY) duration:6];
    SKAction *spin = [SKAction rotateByAngle:-1 duration:1];
    SKAction *remove = [SKAction removeFromParent];
    
    SKAction *spinForever = [SKAction repeatActionForever:spin];
    SKAction *moveAndRemove = [SKAction sequence:@[move, remove]];
    SKAction *all = [SKAction group:@[spinForever, moveAndRemove]];
    [power runAction:all];
    
}

-(void)dropDoublePower {
    CGFloat DoublePowerSize = 60;
    CGFloat startX = arc4random_uniform(self.size.width - 120) + 60;
    CGFloat startY = self.size.height + DoublePowerSize;
    CGFloat EndY = 0 - DoublePowerSize;
    
    SKSpriteNode *DoublePower = [SKSpriteNode spriteNodeWithImageNamed:@"FirePunch"];
    DoublePower.name = @"doublefire";
    DoublePower.size = CGSizeMake(DoublePowerSize * 1.148, DoublePowerSize);
    DoublePower.position = CGPointMake(startX, startY);
    [self addChild:DoublePower];
    
    NSArray *texture = @[[SKTexture textureWithImageNamed:@"FirePunch" ],
                         [SKTexture textureWithImageNamed:@"FirePunch"]];
    
    SKAction *DPAnimation = [SKAction animateWithTextures:texture timePerFrame:0.5];
    SKAction *DPAnimationRepeat = [SKAction repeatActionForever:DPAnimation];
    [DoublePower runAction:DPAnimationRepeat];
    
    SKAction *move = [SKAction moveTo:CGPointMake(startX, EndY) duration:6];
    SKAction *spin = [SKAction rotateByAngle:-1 duration:1];
    SKAction *remove = [SKAction removeFromParent];
    
    SKAction *spinForever = [SKAction repeatActionForever:spin];
    SKAction *moveAndRemove = [SKAction sequence:@[move, remove]];
    SKAction *all = [SKAction group:@[spinForever, moveAndRemove]];
    [DoublePower runAction:all];
}

-(void)dropEnemyType1 {
    CGFloat enemySize = 50;
    CGFloat startX = arc4random_uniform(self.size.width - 80) + 70;
    CGFloat startY = self.size.height + enemySize;
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"enemyship"];
    enemy.size = CGSizeMake(enemySize, enemySize * 1.84);
    enemy.position = CGPointMake(startX, startY);
    enemy.name = @"enemy";
    [self addChild:enemy];
    
    int pathNumber = arc4random_uniform(4) + 1;;
     //int pathNumber = arc4random_uniform(5) + 1;
    CGPathRef enemyPath = [self EnemyMovementPath:pathNumber];
    SKAction *followPath = [SKAction followPath:enemyPath asOffset:YES orientToPath:YES duration:self.durationPath];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *all = [SKAction sequence:@[followPath, remove]];
    [enemy runAction:all];
}

-(void)dropEnemyType2 {
    CGFloat enemySize = 70;
    CGFloat startX = arc4random_uniform(self.size.width - 40) + 60;
    CGFloat startY = self.size.height + enemySize + arc4random_uniform(enemySize);
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"enemyship2"];
    enemy.size = CGSizeMake(enemySize, enemySize);
    enemy.position = CGPointMake(startX, startY);
    enemy.name = @"enemy";
    [self addChild:enemy];
    
    int pathNumber = arc4random_uniform(5) + 1;
    
    CGPathRef enemyPath = [self EnemyMovementPath:pathNumber];
    SKAction *followPath = [SKAction followPath:enemyPath asOffset:YES orientToPath:YES duration:self.durationPath];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *all = [SKAction sequence:@[followPath, remove]];
    [enemy runAction:all];

}

-(void)dropUFO {
    CGFloat ufoSize = 40 + arc4random_uniform(10);
    CGFloat maxX = self.size.width;
    CGFloat quarterX = maxX/4;
    CGFloat startX = arc4random_uniform(maxX + (quarterX * 2)) - quarterX;
    CGFloat startY = self.size.height + ufoSize;
    CGFloat endX = arc4random_uniform(maxX);
    CGFloat endY = 0 - ufoSize;
    
    
    SKSpriteNode *ufo = [SKSpriteNode spriteNodeWithImageNamed:@"meteor0001"];
    NSArray *texture = @[[SKTexture textureWithImageNamed:@"meteor0002"],
                        [SKTexture textureWithImageNamed:@"meteor0003"],
                        [SKTexture textureWithImageNamed:@"meteor0004"],
                        [SKTexture textureWithImageNamed:@"meteor0005"],
                        [SKTexture textureWithImageNamed:@"meteor0006"],
                        [SKTexture textureWithImageNamed:@"meteor0007"],
                        [SKTexture textureWithImageNamed:@"meteor0008"],
                        [SKTexture textureWithImageNamed:@"meteor0009"],
                        [SKTexture textureWithImageNamed:@"meteor0010"],
                        [SKTexture textureWithImageNamed:@"meteor0011"]];
    
    SKAction *ufoAnimation = [SKAction animateWithTextures:texture timePerFrame:0.2];
    SKAction *ufoAnimationRepeat = [SKAction repeatActionForever:ufoAnimation];
    [ufo runAction:ufoAnimationRepeat];
    
    ufo.size = CGSizeMake(ufoSize, ufoSize * 2);
    ufo.position = CGPointMake(startX, startY);
    ufo.name = @"enemy";
    [self addChild:ufo];
    
    SKAction *move = [SKAction moveTo:CGPointMake(endX, endY) duration:3 + arc4random_uniform(4)];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *moveAndRemove = [SKAction sequence:@[move, remove]];
    
    [ufo runAction:moveAndRemove];
}

-(void)dropShield {
    CGFloat ShieldSize = 60;
    CGFloat startX = arc4random_uniform(self.size.width - 160) + 30;
    CGFloat startY = self.size.height + ShieldSize;
    CGFloat EndY = 0 - ShieldSize;
    
    SKSpriteNode *Shield = [SKSpriteNode spriteNodeWithImageNamed:@"Shield"];
    Shield.name = @"Shield";
    Shield.size = CGSizeMake(ShieldSize, ShieldSize * 1.25);
    Shield.position = CGPointMake(startX, startY);
    [self addChild:Shield];
    
    NSArray *texture = @[[SKTexture textureWithImageNamed:@"Shield" ],
                         [SKTexture textureWithImageNamed:@"Shield1"]];
    
    SKAction *ShieldAnimation = [SKAction animateWithTextures:texture timePerFrame:0.5];
    SKAction *ShieldAnimationRepeat = [SKAction repeatActionForever:ShieldAnimation];
    [Shield runAction:ShieldAnimationRepeat];
    
    SKAction *move = [SKAction moveTo:CGPointMake(startX, EndY) duration:6];
    SKAction *spin = [SKAction rotateByAngle:-1 duration:1];
    SKAction *remove = [SKAction removeFromParent];
    
    SKAction *spinForever = [SKAction repeatActionForever:spin];
    SKAction *moveAndRemove = [SKAction sequence:@[move, remove]];
    SKAction *all = [SKAction group:@[spinForever, moveAndRemove]];
    [Shield runAction:all];
    
}

//Enemy Path Movement
-(CGPathRef)EnemyMovementPath:(int)path {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    if (path == 1) {
      
        self.durationPath = 7;
        
        [bezierPath moveToPoint: CGPointMake(-366.5, -1.5)];
        [bezierPath addCurveToPoint: CGPointMake(-164.5, -133.5) controlPoint1: CGPointMake(-366.5, -1.5) controlPoint2: CGPointMake(-164.5, -6.5)];
        [bezierPath addCurveToPoint: CGPointMake(-366.5, -320.5) controlPoint1: CGPointMake(-164.5, -260.5) controlPoint2: CGPointMake(-467.5, -134.5)];
        [bezierPath addCurveToPoint: CGPointMake(-3.5, -518.5) controlPoint1: CGPointMake(-265.5, -506.5) controlPoint2: CGPointMake(31.5, -377.5)];
        [bezierPath addCurveToPoint: CGPointMake(-366.5, -834.5) controlPoint1: CGPointMake(-38.5, -659.5) controlPoint2: CGPointMake(-366.5, -667.75)];
        [bezierPath addCurveToPoint: CGPointMake(-3.5, -1185.5) controlPoint1: CGPointMake(-366.5, -1001.25) controlPoint2: CGPointMake(-3.5, -1185.5)];
        
    }
    else if (path == 2){
        
       self.durationPath = 40;
        
        [bezierPath moveToPoint: CGPointMake(268.5, -0.5)];
        [bezierPath addCurveToPoint: CGPointMake(-600.5, -57.4) controlPoint1: CGPointMake(262.24, -60.68) controlPoint2: CGPointMake(-600.5, -57.4)];
        [bezierPath addLineToPoint: CGPointMake(268.5, -143.85)];
        [bezierPath addLineToPoint: CGPointMake(-600.5, -143.85)];
        [bezierPath addLineToPoint: CGPointMake(268.5, -248.89)];
        [bezierPath addLineToPoint: CGPointMake(-600.5, -299.23)];
        [bezierPath addLineToPoint: CGPointMake(268.5, -369.26)];
        [bezierPath addLineToPoint: CGPointMake(-600.5, -439.29)];
        [bezierPath addLineToPoint: CGPointMake(268.5, -506.04)];
        [bezierPath addLineToPoint: CGPointMake(-600.5, -567.32)];
        [bezierPath addLineToPoint: CGPointMake(268.5, -637.35)];
        [bezierPath addLineToPoint: CGPointMake(-600.5, -686.59)];
        [bezierPath addLineToPoint: CGPointMake(268.5, -761)];
        [bezierPath addLineToPoint: CGPointMake(-600.5, -809.14)];
        [bezierPath addLineToPoint: CGPointMake(268.5, -883.55)];
        [bezierPath addLineToPoint: CGPointMake(-600.5, -927.32)];
        [bezierPath addLineToPoint: CGPointMake(268.5, -997.35)];
        [bezierPath addLineToPoint: CGPointMake(-600.5, -1061.91)];
        [bezierPath addLineToPoint: CGPointMake(268.5, -1106.78)];
        [bezierPath addLineToPoint: CGPointMake(-600.5, -1164.77)];
        [bezierPath addLineToPoint: CGPointMake(268.5, -1254.5)];
    }
    else if (path == 3){
        
        self.durationPath = 7;
        
        [bezierPath moveToPoint: CGPointMake(-206.5, 7.5)];
        [bezierPath addCurveToPoint: CGPointMake(77.5, -216.5) controlPoint1: CGPointMake(-206.5, 7.5) controlPoint2: CGPointMake(55.75, -136.75)];
        [bezierPath addCurveToPoint: CGPointMake(-165.5, -302.5) controlPoint1: CGPointMake(99.25, -296.25) controlPoint2: CGPointMake(-104.75, -236.75)];
        [bezierPath addCurveToPoint: CGPointMake(-165.5, -479.5) controlPoint1: CGPointMake(-226.25, -368.25) controlPoint2: CGPointMake(-222.75, -411)];
        [bezierPath addCurveToPoint: CGPointMake(150.5, -594.5) controlPoint1: CGPointMake(-108.25, -548) controlPoint2: CGPointMake(89.75, -535.25)];
        [bezierPath addCurveToPoint: CGPointMake(-78.5, -790.5) controlPoint1: CGPointMake(211.25, -653.75) controlPoint2: CGPointMake(42.75, -780.25)];
        [bezierPath addCurveToPoint: CGPointMake(-413.5, -790.5) controlPoint1: CGPointMake(-141.86, -795.86) controlPoint2: CGPointMake(-295.5, -569.5)];
        [bezierPath addCurveToPoint: CGPointMake(-206.5, -915.5) controlPoint1: CGPointMake(-521.33, -992.45) controlPoint2: CGPointMake(-246.61, -895.45)];
        [bezierPath addCurveToPoint: CGPointMake(-165.5, -1177.5) controlPoint1: CGPointMake(-122.5, -957.5) controlPoint2: CGPointMake(-165.5, -1177.5)];

        
    }
    else if (path == 4){
        
        self.durationPath = 14;
        
        [bezierPath moveToPoint: CGPointMake(-639.5, -615.5)];
        [bezierPath addCurveToPoint: CGPointMake(-570.5, -296.79) controlPoint1: CGPointMake(-639.5, -615.5) controlPoint2: CGPointMake(-600.75, -296.79)];
        [bezierPath addCurveToPoint: CGPointMake(-518.5, -615.5) controlPoint1: CGPointMake(-540.25, -296.79) controlPoint2: CGPointMake(-518.5, -615.5)];
        [bezierPath addCurveToPoint: CGPointMake(-476.5, -435.5) controlPoint1: CGPointMake(-518.5, -615.5) controlPoint2: CGPointMake(-472.5, -435.5)];
        [bezierPath addCurveToPoint: CGPointMake(-422.5, -615.5) controlPoint1: CGPointMake(-480.5, -435.5) controlPoint2: CGPointMake(-422.5, -615.5)];
        [bezierPath addCurveToPoint: CGPointMake(-345.5, -100.5) controlPoint1: CGPointMake(-422.5, -615.5) controlPoint2: CGPointMake(-413.5, -99.5)];
        [bezierPath addCurveToPoint: CGPointMake(-345.5, -615.5) controlPoint1: CGPointMake(-277.5, -101.5) controlPoint2: CGPointMake(-345.5, -615.5)];
        [bezierPath addLineToPoint: CGPointMake(-262.5, -218.88)];
        [bezierPath addLineToPoint: CGPointMake(-218.5, -615.5)];
        [bezierPath addCurveToPoint: CGPointMake(-155.5, -387.5) controlPoint1: CGPointMake(-218.5, -615.5) controlPoint2: CGPointMake(-223.5, -385.79)];
        [bezierPath addCurveToPoint: CGPointMake(-110.5, -615.5) controlPoint1: CGPointMake(-87.5, -389.21) controlPoint2: CGPointMake(-110.5, -615.5)];
        [bezierPath addCurveToPoint: CGPointMake(-15.5, -387.5) controlPoint1: CGPointMake(-110.5, -615.5) controlPoint2: CGPointMake(-62.25, -387.5)];
        [bezierPath addCurveToPoint: CGPointMake(76.5, -615.5) controlPoint1: CGPointMake(31.25, -387.5) controlPoint2: CGPointMake(76.5, -615.5)];
    }
    else{
        self.durationPath = 9;
        
        [bezierPath moveToPoint: CGPointMake(42.5, 84.5)];
        [bezierPath addCurveToPoint: CGPointMake(-267.5, -131.5) controlPoint1: CGPointMake(42.5, 84.5) controlPoint2: CGPointMake(-242.25, -97)];
        [bezierPath addCurveToPoint: CGPointMake(-100.5, -183.5) controlPoint1: CGPointMake(-292.75, -166) controlPoint2: CGPointMake(-53.5, -153.5)];
        [bezierPath addCurveToPoint: CGPointMake(-455.5, -251.5) controlPoint1: CGPointMake(-147.5, -213.5) controlPoint2: CGPointMake(-436.75, -207.5)];
        [bezierPath addCurveToPoint: CGPointMake(-175.5, -359.5) controlPoint1: CGPointMake(-474.25, -295.5) controlPoint2: CGPointMake(-203.5, -299.5)];
        [bezierPath addCurveToPoint: CGPointMake(-343.5, -491.5) controlPoint1: CGPointMake(-147.5, -419.5) controlPoint2: CGPointMake(-343.5, -399.5)];
        [bezierPath addCurveToPoint: CGPointMake(-175.5, -727.5) controlPoint1: CGPointMake(-343.5, -583.5) controlPoint2: CGPointMake(-175.5, -619.75)];
        [bezierPath addCurveToPoint: CGPointMake(-343.5, -922.5) controlPoint1: CGPointMake(-175.5, -835.25) controlPoint2: CGPointMake(-301.5, -938.75)];
        [bezierPath addCurveToPoint: CGPointMake(-343.5, -662.5) controlPoint1: CGPointMake(-385.5, -906.25) controlPoint2: CGPointMake(-315.5, -727.5)];
        [bezierPath addCurveToPoint: CGPointMake(-455.5, -662.5) controlPoint1: CGPointMake(-371.5, -597.5) controlPoint2: CGPointMake(-401.5, -535.75)];
        [bezierPath addCurveToPoint: CGPointMake(-559.5, -1169.5) controlPoint1: CGPointMake(-509.5, -789.25) controlPoint2: CGPointMake(-559.5, -1169.5)];
        
    }
    
    return bezierPath.CGPath;
}
-(void)didFinishUpdate{
    
    SKNode *hero = [self childNodeWithName:@"hero"];
    CGFloat posX = 0;
    CGFloat posY = 0;
    CGFloat fontSize = 20;
    
    if (_minusHP) {
        if (_HeroHP == 0) {
            SKLabelNode *HP4 = [SKLabelNode labelNodeWithText:@"4"];
            HP4.name = @"HP4";
            HP4.zPosition = 4;
            HP4.position = CGPointMake(posX, posY);
            HP4.fontName = @"AvenirNext-Heavy";
            HP4.fontSize = fontSize;
            HP4.fontColor = [UIColor greenColor];
            [hero addChild:HP4];
        }
        else if (_HeroHP == 1){
            
            SKNode *HP4 = [hero childNodeWithName:@"HP4"];
            [HP4 removeFromParent]; // удаляет предыдущее значение
            
            SKLabelNode *HP3 = [SKLabelNode labelNodeWithText:@"3"];
            HP3.name = @"HP3";
            HP3.zPosition = 4;
            HP3.position = CGPointMake(posX, posY);
            HP3.fontName = @"AvenirNext-Heavy";
            HP3.fontSize = fontSize;
            HP3.fontColor = [UIColor yellowColor];
            [hero addChild:HP3];
            
        }
        else if (_HeroHP == 2){
            
            SKNode *HP3 = [hero childNodeWithName:@"HP3"];
            [HP3 removeFromParent]; // удаляет предыдущее значение
            
            SKLabelNode *HP2 = [SKLabelNode labelNodeWithText:@"2"];
            HP2.name = @"HP2";
            HP2.zPosition = 4;
            HP2.position = CGPointMake(posX, posY);
            HP2.fontName = @"AvenirNext-Heavy";
            HP2.fontSize = fontSize;
            HP2.fontColor = [UIColor orangeColor];
            [hero addChild:HP2];
            
        }
        else if (_HeroHP == 3){
            
            SKNode *HP2 = [hero childNodeWithName:@"HP2"];
            [HP2 removeFromParent]; // удаляет предыдущее значение
            
            SKLabelNode *HP1 = [SKLabelNode labelNodeWithText:@"1"];
            HP1.name = @"HP1";
            HP1.zPosition = 4;
            HP1.position = CGPointMake(posX, posY);
            HP1.fontName = @"AvenirNext-Heavy";
            HP1.fontSize = fontSize;
            HP1.fontColor = [UIColor redColor];
            [hero addChild:HP1];
            
        }
        _minusHP = NO;
    }
    
}



@end
