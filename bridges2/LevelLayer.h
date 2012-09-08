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

#import "cocos2d.h"
#import "GLES-Render.h"
#import "LayerMgr.h"
#import "MyContactListener.h"
#import "PlayerNode.h"
#import "Level.h"
#import "Bridge4Node.h"
#import "LevelController.h"

#define PTM_RATIO 32.0

@interface LevelLayer : CCLayerColor {
    
@private
    b2World *_world;
    
    CCSpriteBatchNode *_spriteSheet;
    GLESDebugDraw *_debugDraw;
    MyContactListener *_contactListener;
    
    PlayerNode *_player;
    
    LayerMgr *_layerMgr;
    
    bool _inCross;
    bool _inBridge;
    
    /*
     * After you visit a house you must cross a 
     * bridge before visiting another one.
     */
    bool _canVisit;
    Bridge4Node *_currentBridge;
    int _bridgeEntry;
    bool _hasInit;
    CGPoint _prevPlayerPos;
    
    CCDirectorIOS	*director_;							// weak ref
}

+ (id) scene;

-(void)setLevel:(Level*) level;
-(void)undo;
-(void)refresh;

@property (nonatomic, retain) PlayerNode *player;
@property (nonatomic, retain) Level *currentLevel;
@property (nonatomic, retain) UIButton *undoBtn;
@property (nonatomic, retain) UILabel *coinLbl;
@property (nonatomic, retain) UIImageView *coinImage;
@property (nonatomic, retain) UIView *view;
@property (readwrite, retain) id<LevelController> controller;
@property (readonly) NSMutableArray *undoStack;


@end