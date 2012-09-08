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

@interface BridgeNode : NSObject <GameNode> {
    int _tag;
    bool _vertical;
    UILabel *_label;
    
}

-(id)initWithOrient: (bool)vertical:(int) tag:(int) color:(LayerMgr*) layerMgr;

-(id)initWithOrientAndDir: (bool)vertical:(int)dir: (int) tag:(int) color:(LayerMgr*) layerMgr;
-(id)initWithOrientAndDirAndCoins: (bool)vertical:(int)dir: (int) tag:(int) color:(LayerMgr*) layerMgr:(int)coins;

-(void)cross;
-(bool)isCrossed;
-(void)setBridgePosition:(CGPoint)p;
-(CGPoint)getBridgePosition;
-(int)tag;

@property (readonly) bool vertical;
@property (readonly) int direction;
@property (readonly, retain) CCSprite *bridge;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, assign, getter=isCrossed, readonly) bool crossed;
@property (readonly) LayerMgr *layerMgr;

@end