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
 * A house node represents a house with a specific color that the player must visit
 * to win the level.
 */
@interface HouseNode : NSObject <GameNode> {
@private
    int _tag;
    LayerMgr *_manager;
    UILabel *_label;
    
}

/**
 * Create a new house with the specified color
 *
 * @param color the color of this house
 * @param layerMgr the layer manager to use for this house instance
 */
-(id)initWithColor:(int) color:(LayerMgr*) layerMgr;

/**
 * Create a new house with the specified color
 *
 * @param color the color of this house
 * @param layerMgr the layer manager to use for this house instance
 * @param coins the number of coins this house can provide
 */
-(id)initWithColorAndCoins:(int) color:(LayerMgr*) layerMgr: (int) coins;

/**
 * Visit this house and subtract one coin.
 */
-(void)visit;

/**
 * True if this house has been visited and false otherwise
 */
-(bool)isVisited;

/**
 * Set the position of this house sprite
 */
-(void)setHousePosition:(CGPoint)p;

/**
 * Get the position of this house sprite
 */
-(CGPoint)getHousePosition;

/**
 * The sprite for this house
 */
@property (readonly, retain) CCSprite *house;


@end