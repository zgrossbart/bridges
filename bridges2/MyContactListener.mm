/*******************************************************************************
 *
 * Copyright 2012 Zack Grossbart
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Original version by Ray Wenderlich on 2/18/10.
 * Copyright 2010 Ray Wenderlich. All rights reserved.
 *
 ******************************************************************************/

#import "MyContactListener.h"
#import "cocos2d.h"
#import "BridgeColors.h"

MyContactListener::MyContactListener() : _contacts() {
}

MyContactListener::~MyContactListener() {
}

/**
 * This method is called when any two objects collide.  Since the game lays bridges
 * over rivers then this method is called constantly.  However, we're only interested
 * in knowing when the player runs into another object to we filter the events and
 * just add events where the player is one side of the contact to our vector.
 */
void MyContactListener::BeginContact(b2Contact* contact) {
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    CCSprite *spriteA = (CCSprite *) contact->GetFixtureA()->GetBody()->GetUserData();
    CCSprite *spriteB = (CCSprite *) contact->GetFixtureB()->GetBody()->GetUserData();
    if (spriteA.tag == PLAYER || spriteB.tag == PLAYER) {
        _contacts.push_back(myContact);
    }
}

void MyContactListener::EndContact(b2Contact* contact) {
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    
    std::vector<MyContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}

void MyContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
}

void MyContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}

