//
//  GamePlayLayer.m
//  PaperToss
//
//  Created by macuser2 on 4/17/14.
//  Copyright (c) 2014 sandeep vasani CSCI 5931.01. All rights reserved.
//

//
//  PuzzleLayer.m
//  PhysicsSample
//
//  Created by CSCI5931 Spring14 on 4/9/14.
//
//

#import "GamePlayLayer.h"
#import "SimpleQueryCallback.h"
#import "Box2DSprite.h"
#import "Box2D.h"
#import "GamePlayScene.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>



#define PTM_RATIO ((UI_USER_INTERFACE_IDIOM() == \
UIUserInterfaceIdiomPad) ? 100.0 : 50.0)


@implementation GamePlayLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        [self setupWorld];
        // [self setupDebugDraw];
        [self scheduleUpdate];
        self.isTouchEnabled = YES;
        [self createGround];
        //   self.isAccelerometerEnabled ;= TRUE;
        //  [self setupDebugDraw];
        [self createSensor];
     
        
         [self createPaperAtLocation:ccp(150, 200)];
         [self createTrashAtLocation];
         [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        for(b2Body *b = world->GetBodyList(); b != NULL; b = b->GetNext()) {
            if (b->GetUserData() != NULL) {
                Box2DSprite *sprite = (Box2DSprite *) b->GetUserData();
                sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                      b->GetPosition().y * PTM_RATIO);
                sprite.rotation = CC_RADIANS_TO_DEGREES(b->GetAngle() * -1);
            }
        }        
    }
    return self;
}






- (void)setupWorld {
    b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
    bool doSleep = true;
    world = new b2World(gravity,doSleep);
}

- (void)dealloc {
    if (world) {
        delete world;
        world = NULL;
    }
    
    if (debugDraw) {
        delete debugDraw;
        debugDraw = nil;
    }
    
    
    [super dealloc];
}

- (void)createPaperAtLocation:(CGPoint)location {
    Box2DSprite *sprite = [Box2DSprite spriteWithFile:@"paper.png"];
    sprite.scaleX=0.5;
    sprite.scaleY=0.5;
   // [self createBodyAtLocation:location forSprite:sprite friction:0.1 restitution:0.3 density:1.0 isBox:FALSE];
    [self addChild:sprite z:5];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    bodyDef.allowSleep = true;
    b2Body *body = world->CreateBody(&bodyDef);
    body->SetUserData(sprite);
    sprite.body = body;
    
    b2FixtureDef fixtureDef;
    
    
        b2CircleShape shape;
        shape.m_radius = sprite.contentSize.width/5/PTM_RATIO;
        fixtureDef.shape = &shape;
   
    
    fixtureDef.density = 1.5;
    fixtureDef.friction = 0.1;
    fixtureDef.restitution = 0.3;
    
    body->CreateFixture(&fixtureDef);
     paper = sprite.body;
    
}
- (void)createTrashAtLocation {
    Box2DSprite *sprite = [Box2DSprite spriteWithFile:@"trash.png"];
    //  sprite.gameObjectType = kSkullType;
   // [self createBodyAtLocation:location forSprite:sprite friction:0.5 restitution:0.5 density:0.25 isBox:FALSE];
    [self addChild:sprite];
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position = b2Vec2((winSize.width*0.9)/PTM_RATIO, (sprite.contentSize.height/2)/PTM_RATIO);
    bodyDef.allowSleep = false;
    b2Body *body = world->CreateBody(&bodyDef);
    body->SetUserData(sprite);
    sprite.body = body;
    
   b2FixtureDef fixtureDef;
	/*
	b2EdgeShape bucketEdge;
	
	bucketEdge.Set(b2Vec2(sprite.position.x-sprite.contentSize.width/2/PTM_RATIO,sprite.position.y+sprite.contentSize.height/2/PTM_RATIO), b2Vec2(sprite.position.x-sprite.contentSize.width/2/PTM_RATIO, sprite.position.y-sprite.contentSize.height/2/PTM_RATIO));
	body->CreateFixture(&fixtureDef);
	
	bucketEdge.Set(b2Vec2(0,0), b2Vec2(0,winSize.height/PTM_RATIO));
    body->CreateFixture(&boxShapeDef);
 
    bucketEdge.Set(b2Vec2(0, winSize.height/PTM_RATIO),
                   b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
    body->CreateFixture(&boxShapeDef);
 
    bucketEdge.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO),
                   b2Vec2(winSize.width/PTM_RATIO, 0));
    body->CreateFixture(&boxShapeDef);
	
	
	*/
	
   b2PolygonShape shape;
    shape.SetAsEdge(b2Vec2(((sprite.position.x+15)-(sprite.contentSize.width)/2)/PTM_RATIO,(sprite.position.y+sprite.contentSize.height/2)/PTM_RATIO), b2Vec2(((sprite.position.x+25)-(sprite.contentSize.width)/2)/PTM_RATIO, (sprite.position.y-sprite.contentSize.height/2)/PTM_RATIO));
    fixtureDef.shape = &shape;
    
    
    fixtureDef.density = 1.0;
    fixtureDef.friction = 0.1;
    fixtureDef.restitution = 0.3;
    
    body->CreateFixture(&fixtureDef);
}


- (void)setupDebugDraw {
    debugDraw = new GLESDebugDraw(PTM_RATIO *[[CCDirector sharedDirector] contentScaleFactor]);
    world->SetDebugDraw(debugDraw);
    debugDraw->SetFlags(b2DebugDraw::e_shapeBit);
}

-(void) draw {
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    world->DrawDebugData();
    
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
                                                     priority:0 swallowsTouches:YES];
}
- (void)createSensor {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGSize sensorSize = CGSizeMake(10, 10);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        sensorSize = CGSizeMake(1, 5);
    }
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position =
    b2Vec2((winSize.width*0.95)/PTM_RATIO,
           (winSize.height*0.1)/PTM_RATIO);
    sensorBody = world->CreateBody(&bodyDef);
    /*
    b2PolygonShape shape;
    shape.SetAsBox(sensorSize.width/PTM_RATIO,  sensorSize.height/PTM_RATIO);
    */
    
    b2CircleShape shape;
    shape.m_radius = 6/PTM_RATIO;
   
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
  //  fixtureDef.isSensor = true;
    sensorBody->CreateFixture(&fixtureDef);
}


-(void)update:(ccTime)dt {
    int32 velocityIterations = 3;
    int32 positionIterations = 2;
    world->Step(dt, velocityIterations, positionIterations);
    
    for(b2Body *b = world->GetBodyList(); b != NULL; b = b->GetNext()) {
        if (b->GetUserData() != NULL) {
            Box2DSprite *sprite = (Box2DSprite *) b->GetUserData();
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                  b->GetPosition().y * PTM_RATIO);
            sprite.rotation = CC_RADIANS_TO_DEGREES(b->GetAngle() * -1);
        }
    }
    
    if (!hasWon) {
        b2ContactEdge* edge = paper->GetContactList();
        while (edge)
        {
            b2Contact* contact = edge->contact;
            b2Fixture* fixtureA = contact->GetFixtureA();
            b2Fixture* fixtureB = contact->GetFixtureB();
            b2Body *bodyA = fixtureA->GetBody();
            b2Body *bodyB = fixtureB->GetBody();
            if (bodyA == sensorBody || bodyB == sensorBody) {
                hasWon = true;
               
                [self win];
                break;
            }
            edge = edge->next;
        }
    }
    
    if(forceApp==true && hasWon==false && (paper->IsAwake()==false) )
    {
        [self lose];
        [self unscheduleUpdate];
    }
    
    
    
}

- (void)lose {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"You Lose!" fontName:@"Helvetica" fontSize:48.0];
    label.position = ccp(winSize.width/2, winSize.height/2);
    label.scale = 0.25;
    [self addChild:label];
    
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:1.0 scale:1.2];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:1.0 scale:1.0];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:2.0];
    CCCallFuncN *winComplete = [CCCallFuncN actionWithTarget:self selector:@selector(winComplete:)];
    CCSequence *sequence = [CCSequence actions:scaleUp, scaleBack, delay, winComplete, nil];
    [label runAction:sequence];
    
    
    CCLabelBMFont *playScene1Label =
    [CCLabelBMFont labelWithString:@"START AGAIN" fntFile:@"VikingSpeechFont64.fnt"];
    CCMenuItemLabel *playScene1 =
    [CCMenuItemLabel itemWithLabel:playScene1Label target:self selector:@selector(playScene:)];
    [playScene1 setTag:1];
    CCMenu *sceneSelectMenu = [CCMenu menuWithItems:playScene1,nil];
    [sceneSelectMenu alignItemsVerticallyWithPadding:winSize.height * 0.059f];
    [sceneSelectMenu setPosition:ccp(winSize.width /2, winSize.height*0.3)];
    [self addChild:sceneSelectMenu];
}

- (void)win {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"You Win!" fontName:@"Helvetica" fontSize:48.0];
    label.position = ccp(winSize.width/2, winSize.height/2);
    label.scale = 0.25;
    [self addChild:label];
    
    CCScaleTo *scaleUp = [CCScaleTo actionWithDuration:1.0 scale:1.2];
    CCScaleTo *scaleBack = [CCScaleTo actionWithDuration:1.0 scale:1.0];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:2.0];
    CCCallFuncN *winComplete = [CCCallFuncN actionWithTarget:self selector:@selector(winComplete:)];
    CCSequence *sequence = [CCSequence actions:scaleUp, scaleBack, delay, winComplete, nil];
    [label runAction:sequence];
    
    
    CCLabelBMFont *playScene1Label =
    [CCLabelBMFont labelWithString:@"START AGAIN" fntFile:@"VikingSpeechFont64.fnt"];
    CCMenuItemLabel *playScene1 =
    [CCMenuItemLabel itemWithLabel:playScene1Label target:self selector:@selector(playScene:)];
    [playScene1 setTag:1];
   CCMenu *sceneSelectMenu = [CCMenu menuWithItems:playScene1,nil];
    [sceneSelectMenu alignItemsVerticallyWithPadding:winSize.height * 0.059f];
    [sceneSelectMenu setPosition:ccp(winSize.width /2, winSize.height*0.3)];
    [self addChild:sceneSelectMenu];
    
}
- (void)winComplete:(id)sender {
    // [[GameManager sharedGameManager] runSceneWithID:kMainMenuScene];
}

-(void)playScene:(id)sender{
 [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GamePlayScene node] ]];

}

/*
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2AABB aabb;
    b2Vec2 delta = b2Vec2(1.0/PTM_RATIO, 1.0/PTM_RATIO);
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    
    aabb.lowerBound = locationWorld - delta;
    aabb.upperBound = locationWorld + delta;
    SimpleQueryCallback callback(locationWorld);
    world->QueryAABB(&callback, aabb);
    if (callback.fixtureFound) {
        
        b2Body *body = callback.fixtureFound->GetBody();
        Box2DSprite *sprite = (Box2DSprite *) body->GetUserData();
        if (sprite == NULL) return FALSE;
        if(![sprite mouseJointBegan]) return FALSE;
        
        b2MouseJointDef mouseJointDef;
        mouseJointDef.bodyA = groundBody;
        mouseJointDef.bodyB = body;
        mouseJointDef.target = locationWorld;
        mouseJointDef.maxForce = 100 * body->GetMass();
        mouseJointDef.collideConnected = true;
        
        mouseJoint = (b2MouseJoint *) world->CreateJoint(&mouseJointDef);
        body->SetAwake(true);
        return YES;
        
    } else {
        //  [self createBoxAtLocation:touchLocation withSize:CGSizeMake(50, 50)];
    }
    
    return TRUE;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    if (mouseJoint) {
        mouseJoint->SetTarget(locationWorld);
    }
}


-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (mouseJoint) {
        world->DestroyJoint(mouseJoint);
        mouseJoint = NULL;
    }
}
*/

-(b2Body *) getBodyAtLocation:(b2Vec2) aLocation {
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
    {
        b2Fixture* bodyFixture = b->GetFixtureList();
        if (bodyFixture->TestPoint(aLocation)){
            return b;
        }
    }
    return NULL;
}



-(b2Vec2) toMeters:(CGPoint)point
{
    return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}


- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    startPoint = [touch locationInView:[touch view]];
    startPoint = [[CCDirector sharedDirector] convertToGL:startPoint];
    
    
    paper2 = [self getBodyAtLocation:[self toMeters:startPoint]];
    return 1;
}



- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

    if (paper2) {
        //this is the maximum force that can be applied
        const CGFloat maxForce = 200;
        
        //get the location of the end point of the swipe
        CGPoint touchLocation = [touch locationInView:[touch view]];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        
        //get the rotation b/w the start point and the end point
        CGFloat rotAngle = atan2f(touchLocation.y - startPoint.y,touchLocation.x - startPoint.x);
        
        //the distance of the swipe if the force
        CGFloat distance = ccpDistance(startPoint, touchLocation) * 0.5;
        
        //put a cap on the force, too much of it will break the rope
        if (distance>maxForce) distance = maxForce;
        forceApp=true;
        //apply force
      //  freeBody->ApplyForce(b2Vec2(cosf(rotAngle) * distance, sinf(rotAngle) * distance), freeBody->GetPosition());
        paper->ApplyLinearImpulse(b2Vec2(cosf(rotAngle) * distance, sinf(rotAngle) * distance), paper->GetWorldCenter());
        //lose the weak reference to the body for next time usage.
        paper2 = nil;
    }
    
   
}


- (void)createGround {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float32 margin = 10.0f;
    b2Vec2 lowerLeft = b2Vec2(margin/PTM_RATIO, margin/PTM_RATIO);
    b2Vec2 lowerRight = b2Vec2((winSize.width-margin)/PTM_RATIO,
                               margin/PTM_RATIO);
    b2Vec2 upperRight = b2Vec2((winSize.width-margin)/PTM_RATIO,
                               (winSize.height-margin)/PTM_RATIO);
    b2Vec2 upperLeft = b2Vec2(margin/PTM_RATIO,
                              (winSize.height-margin)/PTM_RATIO);
    
    b2BodyDef groundBodyDef;
    groundBodyDef.type = b2_staticBody;
    groundBodyDef.position.Set(0, 0);
    groundBody = world->CreateBody(&groundBodyDef);
    
    b2PolygonShape groundShape;
    b2FixtureDef groundFixtureDef;
    groundFixtureDef.shape = &groundShape;
    groundFixtureDef.density = 0.0;
    
    groundShape.SetAsEdge(lowerLeft, lowerRight);
    groundBody->CreateFixture(&groundFixtureDef);
    groundShape.SetAsEdge(lowerRight, upperRight);
    groundBody->CreateFixture(&groundFixtureDef);
    groundShape.SetAsEdge(upperRight, upperLeft);
    groundBody->CreateFixture(&groundFixtureDef);
    groundShape.SetAsEdge(upperLeft, lowerLeft);
    groundBody->CreateFixture(&groundFixtureDef);
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    b2Vec2 gravity(-acceleration.y * 15, acceleration.x *15);
    world->SetGravity(gravity);
}




@end
