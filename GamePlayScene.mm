//
//  GamePlayScene.m
//  PaperToss
//
//  Created by macuser2 on 4/17/14.
//  Copyright (c) 2014 sandeep vasani CSCI 5931.01. All rights reserved.
//

#import "GamePlayScene.h"
#import "GamePlayLayer.h"


@implementation GamePlayScene

-(id)init {
    self = [super init];
    if (self != nil) {
       GamePlayScene *gameplayLayer = [GamePlayLayer node];
        [self addChild:gameplayLayer];
    }
    return self;
}

@end
