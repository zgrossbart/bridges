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

#import "BridgeColors.h"

/**
 * A game node represents an object on the game board the user can interact 
 * with like a bridge,  house, subway, or teleporter.
 */
@protocol GameNode <NSObject>
@required

/**
 * Called when this node should add it's sprite to the sprite sheet.
 */
-(void) addSprite;

/**
 * Get the list of UIControls, like the coin label, associated with this node.
 */
-(NSArray*) controls;

/**
 * Undoes the previous action taken on this node.
 */
-(void) undo;

/**
 * The tag that uniquely identifies this type of node.
 */
@property (nonatomic, assign, readonly) int tag;

/**
 * The number of coins for this node.  Some nodes use this value to store
 * the number of coins they have available and others use it to store the 
 * number of coins they require.
 */
@property (nonatomic, assign, readonly) int coins;

/**
 * The color of this node
 */
@property (nonatomic, assign, readonly) BridgeColor color;

@end