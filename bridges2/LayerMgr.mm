//
//  LayerMgr.m
//  bridges
//
//  Created by Zack Grossbart on 8/25/12.
//
//

#import "LayerMgr.h"

@implementation LayerMgr

+(CGFloat) distanceBetweenTwoPoints: (CGPoint) point1: (CGPoint) point2 {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy );
}

CCSpriteBatchNode *_sheet;

-(id) initWithSpriteSheet:(CCSpriteBatchNode*) spriteSheet:(b2World*) world {
    _sheet = spriteSheet;
    _world = world;
    return self;
}

-(void)addChildToSheet:(CCSprite*) sprite {
    [self addBoxBodyForSprite:sprite];
    [_sheet addChild:sprite];
}

-(void)addBoxBodyForSprite:(CCSprite *)sprite {
    
    b2BodyDef spriteBodyDef;
    spriteBodyDef.type = b2_dynamicBody;
    spriteBodyDef.position.Set(sprite.position.x/PTM_RATIO,
                               sprite.position.y/PTM_RATIO);
    spriteBodyDef.userData = sprite;
    b2Body *spriteBody = _world->CreateBody(&spriteBodyDef);
    
    b2PolygonShape spriteShape;
    spriteShape.SetAsBox(sprite.contentSize.width/PTM_RATIO/2,
                         sprite.contentSize.height/PTM_RATIO/2);
    b2FixtureDef spriteShapeDef;
    spriteShapeDef.shape = &spriteShape;
    spriteShapeDef.density = 10.0;
    spriteShapeDef.isSensor = true;
    spriteBody->CreateFixture(&spriteShapeDef);
    
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
    
    [_sheet removeChild:sprite cleanup:YES];
    
}

-(void)dealloc {
    
    [_sheet release];
    [super dealloc];
}


@end
