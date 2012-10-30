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
 * A teleport node represents a teleporter where you can enter in a fixed point and 
 * jump out anywhere
 */
@interface TeleportNode : NSObject <GameNode> {
}

/**
 * Create a new teleport node
 *
 * @param color the color constant for this teleporter
 * @param layerMgr the layer manager instance to add sprites to
 */
-(id)initWithColor: (BridgeColor) color :(LayerMgr*) layerMgr;

/**
 * Jump through this teleporter
 */
-(void)jump;

/**
 * The sprite of the teleporter
 */
@property (readonly, retain) CCSprite *teleporter;

@end