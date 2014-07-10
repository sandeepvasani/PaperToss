//
//  Box2DSprite.h
//  PhysicsSample
//
//  Created by macuser2 on 4/16/14.
//
//

#import "CCSprite.h"
#import "Box2D.h"

@interface Box2DSprite : CCSprite
@property (assign) b2Body *body;
- (BOOL) mouseJointBegan;

@end
