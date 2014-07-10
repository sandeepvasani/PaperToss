//
//  SimpleQueryCallback.h
//  PhysicsSample
//
//  Created by macuser2 on 4/16/14.
//
//

#ifndef PhysicsSample_SimpleQueryCallback_h
#define PhysicsSample_SimpleQueryCallback_h



#endif


class SimpleQueryCallback : public b2QueryCallback
{
public:
    b2Vec2 pointToTest;
    b2Fixture * fixtureFound;
    
    SimpleQueryCallback(const b2Vec2& point) {
        pointToTest = point;
        fixtureFound = NULL;
    }
    
    
    bool ReportFixture(b2Fixture* fixture) {
        b2Body* body = fixture->GetBody();
        if (body->GetType() == b2_dynamicBody) {
            if (fixture->TestPoint(pointToTest)) {
                fixtureFound = fixture;
                return false;
            }
        }
        return true;
    }
};