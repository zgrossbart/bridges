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

@interface Bridge4Node : NSObject <GameNode> {
    int _tag;
    
}

-(id)initWithTagAndColor: (int) tag:(int) color:(LayerMgr*) layerMgr;

-(void)cross;
-(void)enterBridge:(int)dir;
-(bool)isCrossed;
-(void)setBridgePosition:(CGPoint)p;
-(CGPoint)getBridgePosition;
-(int)tag;

@property (readonly, retain) CCSprite *bridge;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, assign, getter=isCrossed, readonly) bool crossed;
@property (readonly) LayerMgr *layerMgr;

@end