//
//  SKEmitterNode+Extensions.h
//  SpaceGame
//
//  Created by Никита Шарапов on 04.11.15.
//  Copyright © 2015 Никита Шарапов. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKEmitterNode (Extensions)

+(SKEmitterNode *)nodeWithFile:(NSString *)filename;
-(void)dieInDuration:(NSTimeInterval)duration;



@end
