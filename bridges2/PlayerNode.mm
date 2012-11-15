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

#import "PlayerNode.h"
#import "BridgeColors.h"

@interface PlayerNode()
@property (readwrite, retain) CCSprite *player;
@property (nonatomic, assign, readwrite) BridgeColor color;
@property (nonatomic, retain) CCAction *walkAction;
@property (nonatomic, retain) CCAction *moveAction;
@end

@implementation PlayerNode

@synthesize player = _player;
@synthesize moveAction = _moveAction;
@synthesize walkAction = _walkAction;

-(id)initWithColor:(BridgeColor) color:(LayerMgr*) layerMgr {
    if( (self=[super init] )) {
        _manager = layerMgr;
        _tag = PLAYER;
        self.color = color;
        if (color == cRed) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1_red.png"]];
        } else if (color == cBlue) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1_blue.png"]];
        } else if (color == cGreen) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1_green.png"]];
        } else if (color == cOrange) {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1_orange.png"]];
        } else {
            [self setPlayerSprite:[CCSprite spriteWithSpriteFrameName:@"octopus1.png"]];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.player.scale = IPAD_SCALE_FACTOR;
        }
        
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 5; ++i) {
            [walkAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"octopus%d.png", i]]];
        }
        
        CCAnimation *walkAnim = [CCAnimation
                                 animationWithSpriteFrames:walkAnimFrames delay:0.1f];
        self.walkAction = [CCRepeatForever actionWithAction:
                           [CCAnimate actionWithAnimation:walkAnim]];
        
        _spriteBody = [_manager addChildToSheet:self.player:YES];
    }
    
    return self;
}

-(b2Body*)getSpriteBody {
    return _spriteBody;
}

-(void)playerMoveEnded {
    [_player stopAction:_walkAction];
    _moving = FALSE;
    [self updateColor:self.color];
    
    /*
     * If this move caused us to collide with something (like crossing 
     * a bridge) then the bounding box for our sprite gets stuck against
     * the item we collided with until the next click.  We need to manually
     * update the position so the next click can move the player sprite
     * properly instead of just repositioning the box.
     */
    _spriteBody->SetTransform(b2Vec2(self.player.position.x,self.player.position.y), _spriteBody->GetAngle());
}

-(void)updateColor:(BridgeColor)color {
    self.color = color;
    
    CCSpriteFrameCache* cache = [CCSpriteFrameCache sharedSpriteFrameCache];
    CCSpriteFrame* frame;
    
    if (color == cRed) {
        frame = [cache spriteFrameByName:@"octopus1_red.png"];
    } else if (color == cBlue) {
        frame = [cache spriteFrameByName:@"octopus1_blue.png"];
    } else if (color == cGreen) {
        frame = [cache spriteFrameByName:@"octopus1_green.png"];
    } else if (color == cOrange) {
        frame = [cache spriteFrameByName:@"octopus1_orange.png"];
    } else {
        frame = [cache spriteFrameByName:@"octopus1.png"];
    }
    
    [self.player setDisplayFrame:frame];
}

-(void)setPlayerSprite:(CCSprite*)player {
    self.player = player;
    self.player.tag = [self tag];
}

-(void)moveTo:(CGPoint)p:(bool)force {
    if (force) {
        _moving = false;
    }
    
    [self moveTo:p];
}

-(void)jumpTo:(CGPoint)p {
    if (_moving) {
        /*
         * If we're already moving then we just ignore
         * new requests to move.
         */
        return;
    }
    
    CGFloat distance = [LayerMgr distanceBetweenTwoPoints:_player.position: p];
    float velocity = 240/1; // 240pixels/1sec
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        velocity = velocity * 2;
    }
    
    _moving = TRUE;
    CCSequence* seq = [CCSequence actions:[CCJumpTo actionWithDuration:distance/velocity position:p height:50 jumps:1],
                       [CCCallFunc actionWithTarget:self selector:@selector(playerMoveEnded)], nil];
    [self.player runAction:seq];
}

-(void)moveTo:(CGPoint)p {
    if (_moving) {
        /*
         * If we're already moving then we just ignore 
         * new requests to move.
         */
        return;
    }
    
    [_player runAction:_walkAction];
    
    CGFloat distance = [LayerMgr distanceBetweenTwoPoints:_player.position: p];
    float velocity = 340/1; // 340pixels/1sec
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        velocity = velocity * 2;
    }
    
    _moving = TRUE;
    self.moveAction = [CCSequence actions:
                       [CCMoveTo actionWithDuration:distance/velocity position:p],
                       [CCCallFunc actionWithTarget:self selector:@selector(playerMoveEnded)],
                       nil
                       ];

    [_player runAction:self.moveAction];
}

-(int)tag {
    return _tag;
}

-(void)dealloc {
    /*
     * We don't need to deallocate the player sprite
     * since it was removed from the sprite sheet and
     * that deallocates it for us.
     *
     * [self.player dealloc];
     */
    
    self.player = nil;
    self.walkAction = nil;
    
    [super dealloc];
}

@end
