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

@interface HouseNode : NSObject <GameNode> {
@private
    int _tag;
    LayerMgr *_manager;
    UILabel *_label;
    
}

-(id)initWithColor:(int) tag:(int) color:(LayerMgr*) layerMgr;
-(id)initWithColorAndCoins:(int) tag:(int) color:(LayerMgr*) layerMgr: (int) coins;

-(void)visit;
-(bool)isVisited;
-(void)setHousePosition:(CGPoint)p;
-(CGPoint)getHousePosition;
-(int)tag;

@property (readonly, retain) CCSprite *house;
@property (nonatomic, assign, getter=isVisited, readonly) bool visited;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, assign, setter=position:) CGPoint position;
@property (readonly) LayerMgr *layerMgr;

@end