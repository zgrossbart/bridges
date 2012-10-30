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
#import "BridgeColors.h"

#define PTM_RATIO 32.0

/** 
 * The LevelLayer handles all of the user interactions for a level.
 * It also takes care of interactions with nodes and handling the 
 * undo chain.  This means the LevelLayer has knowledge of each node
 * which violates object-oriented ideals, but it can isolate it's
 * implementation from the other nodes by doing that and simplifies
 * the code since the game support a relatively small number of
 * nodes.
 */
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
    bool _inMove;
    bool _inJump;
    CCSprite *_subwayEnd;
    
    /*
     * After you visit a house you must cross a 
     * bridge before visiting another one.
     */
    bool _canVisit;
    Bridge4Node *_currentBridge;
    BridgeDir _bridgeEntry;
    bool _hasInit;
    CGPoint _prevPlayerPos;
    
    CCDirectorIOS	*director_;							// weak ref
}

/** 
 * The factory method for getting a static instance of a 
 * scene containing this layer.
 */
+ (id) scene;

/** 
 * Set the specified level as the current level.
 *
 * @param level the level to play
 */
-(void)setLevel:(Level*) level;

/** 
 * Undo the last player move resetting and node interactions.
 */
-(void)undo;

/** 
 * Refresh the current level by resetting all nodes and restoring
 * the level state to the original state in the level definition.
 */
-(void)refresh;

/**
 * Reset the level layer by removing all objects so it's ready to 
 * show a new level.
 */
-(void)reset;

/** 
 * Holds the current level this layer is working work
 */
@property (nonatomic, retain) Level *currentLevel;

/** 
 * Sets the undo button so the layer can enable and disable it correctly.
 */
@property (nonatomic, retain) UIButton *undoBtn;

/** 
 * The coin label shows the current number of coins the player has.
 */
@property (nonatomic, retain) UILabel *coinLbl;

/** 
 * The coin image is a simple decorator for the coin label.  It's 
 * hidden if the current label doesn't use coins.
 */
@property (nonatomic, retain) UIImageView *coinImage;

/** 
 * The UIKit view associated with this layer.  It's used for node labels
 * and other controls not renderred by Cocos2d.
 */
@property (nonatomic, retain) UIView *view;

/** 
 * The controller for this level
 */
@property (readwrite, retain) id<LevelController> controller;

@end