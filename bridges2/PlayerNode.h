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

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"
#import "BridgeColors.h"

/** 
 * The player node is a special game node which represents the 
 * active player.  Unlike other nodes the player node can move
 * and interact with other nodes.
 */
@interface PlayerNode : NSObject {
@private
    int _tag;
    LayerMgr *_manager;
    b2Body *_spriteBody;
    CCAction *_walkAction;
    CCAction *_moveAction;
    BOOL _moving;
    
}

/** 
 * Create a new player with the specified color.
 *
 * @param color the color for this player
 * @param layerMgr the layer manager used to handle the player sprites
 */
-(id)initWithColor:(BridgeColor) color:(LayerMgr*) layerMgr;

/** 
 * The player can change color by walking over colored bridges.  This
 * method updates the players color when crossing a bridge.
 *
 * @param color the new color
 */
-(void)updateColor:(BridgeColor)color;

/** 
 * Gets the tag for this node.  It is always PLAYER
 */
-(int)tag;

/**
 * Move the player to specified position with a jumping effect.  The player
 * will jump over any objects in the way.
 *
 * @param p the new player position
 */
-(void)jumpTo:(CGPoint)p;

/** 
 * Move the player to specified position.  The player will stop if it
 * collides with another object while moving to the specified point.
 *
 * @param p the new player position
 */
-(void)moveTo:(CGPoint)p;

/**
 * Move the player to specified position.  The player will stop if it
 * collides with another object while moving to the specified point.
 *
 * @param p the new player position
 * @param force normally moves are ignored if the player is already
 *              moving.  This flag forces the move even if the player
 *              is in the middle of a move.
 */
-(void)moveTo:(CGPoint)p:(bool)force;

/** 
 * Called to update the player node and indicate a move operation is 
 * complete.
 */
-(void)playerMoveEnded;

/**
 * Get the Box2d body for the player for managing collision detection.
 */
-(b2Body*)getSpriteBody;

/** 
 * The player sprite representing this node.
 */
@property (readonly, retain) CCSprite *player;

/** 
 * The current color of this player.
 */
@property (nonatomic, assign, readonly) BridgeColor color;

/** 
 * The number of coins the player currently has.
 */
@property (nonatomic, assign, readwrite) int coins;

@end