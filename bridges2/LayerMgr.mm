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
 ******************************************************************************/

#import "LayerMgr.h"

@implementation LayerMgr {
    CCSpriteBatchNode *_sheet;
}

+(CGFloat) distanceBetweenTwoPoints: (CGPoint) point1: (CGPoint) point2 {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
}



-(id) initWithSpriteSheet:(CCSpriteBatchNode*) spriteSheet:(b2World*) world {
    _sheet = spriteSheet;
    _world = world;
    self.addBoxes = true;
    return self;
}

-(b2Body*)addChildToSheet:(CCSprite*) sprite {
    return [self addChildToSheet:sprite :FALSE];
}

-(b2Body*)addChildToSheet:(CCSprite*) sprite: (bool) bullet {
    
    b2Body *body = nil;
    
    if (self.addBoxes) {
        body = [self addBoxBodyForSprite:sprite:YES];
    }
    
    [_sheet addChild:sprite];
    
    return body;
}

-(b2Body*)addBoxBodyForSprite:(CCSprite *)sprite {
    return [self addBoxBodyForSprite:sprite:NO];
}

-(b2Body*)addBoxBodyForSprite:(CCSprite *)sprite: (bool) bullet {
    
    b2BodyDef spriteBodyDef;
    spriteBodyDef.bullet = bullet;
    if (bullet) {
        spriteBodyDef.type = b2_dynamicBody;
        spriteBodyDef.allowSleep = NO;
    } else {
        spriteBodyDef.type = b2_staticBody;
    }
    spriteBodyDef.position.Set(sprite.position.x/PTM_RATIO,
                               sprite.position.y/PTM_RATIO);
    spriteBodyDef.userData = sprite;
    spriteBodyDef.fixedRotation = YES;
    b2Body *spriteBody = _world->CreateBody(&spriteBodyDef);
    
    b2PolygonShape spriteShape;
    spriteShape.SetAsBox(sprite.contentSize.width/PTM_RATIO/2,
                         sprite.contentSize.height/PTM_RATIO/2);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 1;
    spriteShapeDef.restitution = 1;
    spriteShapeDef.friction = 1;
    spriteShapeDef.isSensor = true;
    spriteBody->CreateFixture(&spriteShapeDef);

    return spriteBody;
    
}

-(void)removeAll {
    for (int i = _sheet.children.count - 1; i >= 0; i--) {
        [self spriteDone:[_sheet.children objectAtIndex:i]];
    }
    
//    NSLog(@"children.count: %i", _sheet.children.count);
}

-(void)spriteDone:(id)sender {
    
    CCSprite *sprite = (CCSprite *)sender;
    
    b2Body *spriteBody = NULL;
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *curSprite = (CCSprite *)b->GetUserData();
            if (sprite == curSprite) {
                spriteBody = b;
                break;
            }
        }
    }
    if (spriteBody != NULL) {
        _world->DestroyBody(spriteBody);
    }
    
    [_sheet removeChild:sprite cleanup:NO];
    
}

/*
 * UIKit counts from the upper left, but Cocos2d counts from
 * the bottom left so we need to calculate the Y position to
 * compensate for that.
 */
+(float)normalizeYForControl:(float) y {
    return [[CCDirector sharedDirector] winSize].height - y;
}

-(void)dealloc {
    
    [_sheet release];
    [super dealloc];
}


@end
