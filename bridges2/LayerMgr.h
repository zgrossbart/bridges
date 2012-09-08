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

@interface LayerMgr : NSObject {
    b2World *_world;
}

+(CGFloat) distanceBetweenTwoPoints: (CGPoint) point1: (CGPoint) point2;
+(float)normalizeYForControl:(float) y;

-(id) initWithSpriteSheet:(CCSpriteBatchNode*) spriteSheet:(b2World*) world;
-(b2Body*)addChildToSheet:(CCSprite*) sprite;
-(b2Body*)addBoxBodyForSprite:(CCSprite *)sprite;
-(void)spriteDone:(id)sender;
-(void)removeAll;


@property (readwrite) CGSize tileSize;

@end