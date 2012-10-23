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
#import "Box2D.h"

#define PTM_RATIO 32.0
/**
 * The layer manager manages the interactions between sprites, the sprite
 * sheet, and the box model which looks for collisions.  It also provides
 * some utility methods for doing math on coordinates in the game layer.
 */
@interface LayerMgr : NSObject {
    @private
    b2World *_world;
}

/**
 * Calculate the difference between two points.
 */
+(CGFloat) distanceBetweenTwoPoints: (CGPoint) point1: (CGPoint) point2;

/**
 * Cocos2d calculates all coordinates with the bottom left of the screen as
 * the 0,0 point.  UIKit puts that point in the top left.  This method will
 * take a coordinate from the UIKit coordinate system and convert if to the
 * Cocos2d system.
 */
+(float)normalizeYForControl:(float) y;

/**
 * Create a new LayerManager
 *
 * @param spriteSheet the sprite sheet for managing sprites
 * @param world the box2d world for this game layer
 */
-(id) initWithSpriteSheet:(CCSpriteBatchNode*) spriteSheet:(b2World*) world;

/**
 * Add a sprite to the sprite sheet for display
 *
 * @param sprite the sprite to add
 *
 * @return the box2d body for this sprite
 */
-(b2Body*)addChildToSheet:(CCSprite*) sprite;

/**
 * Add a sprite to the parent of the sprite sheet for display
 *
 * @param sprite the sprite to add
 *
 * @return the box2d body for this sprite
 */
-(b2Body*)addChildToSheetParent:(CCSprite*) sprite;

/**
 * Add a sprite to the sprite sheet for display
 *
 * @param sprite the sprite to add
  * @param bullet true if this item is a fast moving "bullet" like the player
 *
 * @return the box2d body for this sprite
 */
-(b2Body*)addChildToSheet:(CCSprite*) sprite: (bool) bullet;

/**
 * Add a box2d body for this sprite to support collision detection.
 *
 * @param sprite the sprite to add
 *
 * @return the box2d body for this sprite
 */
-(b2Body*)addBoxBodyForSprite:(CCSprite *)sprite;

/**
 * Add a box2d body for this sprite to support collision detection.
 *
 * @param sprite the sprite to add
 * @param bullet true if this item is a fast moving "bullet" like the player
 *
 * @return the box2d body for this sprite
 */
-(b2Body*)addBoxBodyForSprite:(CCSprite *)sprite: (bool) bullet;

/**
 * Remove all the sprites from the sprite sheet.  This is called when reloading a
 * level or clearing out the previous level to load a new one.
 */
-(void)removeAll;

/**
 * This property shows holds the size of a tile.  Each game board is 28
 * tiles tall and all levels specify coordinates using tiles instead of
 * pixels or points.  The tiles change size depending on the size of the
 * screen.
 */
@property (readwrite) CGSize tileSize;

/**
 * This property determines if the layer manager will draw boxes around each
 * sprite or not.  The boxes are what Box2d uses to do collision detection.
 * We need boxes when we're playing the level, but we don't want them when 
 * we're just rendering the layer screen shot.
 */
@property (readwrite) bool addBoxes;

@end