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
#import "GameNode.h"
#import "BridgeColors.h"

/**
 * A bridge node represents a single two-way bridge in the game
 */
@interface BridgeNode : NSObject <GameNode> {
    
    @private
    bool _vertical;
}

/**
 * Create a new bridge node
 *
 * @param vertical true if this bridge is vertical and false if it's horizontal
 * @param color the color constant for this bridge
 * @param layerMgr the layer manager instance to add sprites to
 */
-(id)initWithOrient: (bool) vertical :(BridgeColor) color :(LayerMgr*) layerMgr;

/**
 * Create a new bridge node
 *
 * @param vertical true if this bridge is vertical and false if it's horizontal
 * @param dir the direction of the bridge.  Players can only cross in this direction
 * @param color the color constant for this bridge
 * @param layerMgr the layer manager instance to add sprites to
 */
-(id)initWithOrientAndDir: (bool) vertical:(BridgeDir) dir: (BridgeColor) color:(LayerMgr*) layerMgr;

/**
 * Create a new bridge node
 *
 * @param vertical true if this bridge is vertical and false if it's horizontal
 * @param dir the direction of the bridge.  Players can only cross in this direction
 * @param color the color constant for this bridge
 * @param layerMgr the layer manager instance to add sprites to
 * @param coins the number of coins it costs to completely cross this bridge
 */
-(id)initWithOrientAndDirAndCoins: (bool) vertical:(BridgeDir) dir: (BridgeColor) color:(LayerMgr*) layerMgr:(int) coins;

/**
 * Cross this bridge.  This will decrement the coin count or disable the bridge if there
 * are no more coins.
 */
-(void)cross;

/**
 * True if this bridge has been completely crossed and false otherwise
 */
-(bool)isCrossed;

/**
 * Set the position of this bridge's sprite and count label.
 *
 * @param p the position for the bridge
 */
-(void)setBridgePosition:(CGPoint)p;

/**
 * Get the position of this bridge sprite
 */
-(CGPoint)getBridgePosition;

/**
 * True if this bridge is vertical and false otherwise
 */
@property (readonly) bool vertical;

/**
 * The direction of this bridge:  UP, DOWN, LEFT, or RIGHT
 */
@property (readonly) int direction;

/**
 * The sprite which draws the bridge image
 */
@property (readonly, retain) CCSprite *bridge;

/**
 * True if this bridge has been crossed and false otherwise
 */
@property (nonatomic, assign, getter=isCrossed, readonly) bool crossed;

@end