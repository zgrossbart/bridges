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

/**
 * This node represents a 4-way bridge.  The player can enter in one direction
 * and exit through one of the three remaining directions.
 */
@interface Bridge4Node : NSObject <GameNode> {
    @private
    int _tag;
}

/**
 * Create a new 4-way bridge
 *
 * color the color of this bridge
 * the layer manager for use with this node
 */
-(id)initWithTagAndColor: (int)color: (LayerMgr*)layerMgr;

/**
 * Called to finish crossing the bridge after enterring and choosing an exit direction
 */
-(void)cross;

/**
 * Enter the bridge at the specified direction.  The player then waits
 * in the middle of the bridge until another tap determines the exit
 * direction.
 *
 * @param dir the direction the player enterred from
 */
-(void)enterBridge:(int)dir;

/**
 * True if this bridge is crossed and false otherwise
 */
-(bool)isCrossed;

/**
 * Set the position of this bridge sprite
 *
 */
-(void)setBridgePosition:(CGPoint)p;

/**
 * Get the position of this bridgr sprite
 */
-(CGPoint)getBridgePosition;

/**
 * The sprite for this bridge
 */
@property (readonly, retain) CCSprite *bridge;

@end