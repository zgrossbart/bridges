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

@interface PlayerNode : NSObject {
@private
    int _tag;
    LayerMgr *_manager;
    
    CCSprite *_playerSprite;
    b2Body *_spriteBody;
    CCAction *_walkAction;
    CCAction *_moveAction;
    BOOL _moving;
    
}

-(id)initWithTag:(int) tag:(int) color:(LayerMgr*) layerMgr;
-(void)updateColor:(int)color;
-(int)tag;
-(void)moveTo:(CGPoint)p;
-(void)moveTo:(CGPoint)p:(bool)force;
-(void)playerMoveEnded;

@property (readonly) CCSprite *player;
@property (nonatomic, assign, readonly) int color;
@property (nonatomic, retain) CCAction *walkAction;
@property (nonatomic, retain) CCAction *moveAction;
@property (nonatomic, assign, readwrite) int coins;

@end