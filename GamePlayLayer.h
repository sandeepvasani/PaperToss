//
//  GamePlayLayer.h
//  PaperToss
//
//  Created by macuser2 on 4/17/14.
//  Copyright (c) 2014 sandeep vasani CSCI 5931.01. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@interface GamePlayLayer : CCLayer{
b2World * world;
GLESDebugDraw * debugDraw;
b2Body *groundBody;
b2MouseJoint *mouseJoint;
CCSpriteBatchNode *sceneSpriteBatchNode;
b2Body *paper;
b2Body *paper2;
CGPoint startPoint;
b2Body *sensorBody;
BOOL hasWon;
bool forceApp;
}
@end
