//
//  GameScene.m
//  SpaceGame
//
//  Created by Никита Шарапов on 04.11.15.
//  Copyright (c) 2015 Никита Шарапов. All rights reserved.
//

#import "TitleScene.h"
#import "GameScene.h"
#import "Stars.h"
#import "SKEmitterNode+Extensions.h"
#import "GameStartNode.h"
#import "Level1.h"

@implementation TitleScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {

        
        self.backgroundColor = [SKColor blackColor];
        
        //Stars
        Stars *starsField = [Stars node];
        [self addChild:starsField];
        
        //Hero
        SKSpriteNode *hero = [SKSpriteNode spriteNodeWithImageNamed:@"hero"];
        hero.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:hero];
        
        //Fire
        SKEmitterNode *leftEngine = [SKEmitterNode nodeWithFile:@"fireBig.sks"];
        leftEngine.position = CGPointMake(-19, -57);
        [hero addChild:leftEngine];
        
        SKEmitterNode *rightEngine = [SKEmitterNode nodeWithFile:@"fireBig.sks"];
        rightEngine.position = CGPointMake(+19, -57);
        [hero addChild:rightEngine];
        
        // Game Start Text
        GameStartNode *gameStartNode = [GameStartNode node];
        gameStartNode.position = CGPointMake(self.size.width/2, self.size.height - 120);
        [self addChild:gameStartNode];
        
        //HightScore
        NSNumberFormatter *scoreFormatter = [[NSNumberFormatter alloc]init];
        scoreFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:@{@"highScore":@0}];
        
        NSNumber *score = [defaults valueForKey:@"highScore"];
        NSString *scoreText = [NSString stringWithFormat:@"Higth Score: %@", [scoreFormatter stringFromNumber:score]];
        
        SKLabelNode *instructions = [SKLabelNode labelNodeWithFontNamed:@"Copperplate"];
        instructions.fontSize = 24;
        instructions.color = [SKColor whiteColor];
        instructions.text = scoreText;
        instructions.position = CGPointMake(self.size.width/2, 70);
        [self addChild:instructions];
    }
    return self;
    
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //Level1 * gameScene = [Level1 sceneWithSize:self.frame.size];
    //[self.view presentScene:gameScene];
    
    
    GameScene *gameScene = [GameScene sceneWithSize:self.frame.size];
    SKTransition *transition = [SKTransition fadeWithDuration:1.0];
    [self.view presentScene:gameScene transition:transition];
     
    
}


@end
