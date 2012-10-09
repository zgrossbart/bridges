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
#import "GameNode.h"
#import "BridgeColors.h"

/** 
 * Undoables represent a game action which the user can undo.
 * The undoable doesn't perform the undo, but acts as a struct
 * for the level layer and level to use while undoing the action.
 */
@interface Undoable : NSObject

/** 
 * Create a new undoable.
 *
 * @param pos the previous position of the player
 * @param node the node the player interacted with to cause this undoable event
 * @param color the previous color of the player
 * @param coins the previous coin count of the player
 * @param canVisit if the user can visit houses or not
 */
-(id) initWithPosAndNode:(CGPoint) pos:(id<GameNode>) node: (BridgeColor) color: (int) coins: (bool) canVisit;

/** 
 * The previous player position
 */
@property (readonly) CGPoint pos;

/** 
 * The game node for this undoable
 */
@property (readonly, assign) id<GameNode> node;

/** 
 * The previous player color
 */
@property (readonly) BridgeColor color;

/** 
 * The previous coin count of the player
 */
@property (nonatomic, assign, readonly) int coins;

/**
 * If the player visits a house they must leave the current island
 * before they can visit another one.  This property holds the value
 * that controls if the user can visit more houses.
 */
@property (nonatomic, assign, readonly) bool canVisit;


@end
