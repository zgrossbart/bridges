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

#import "LevelLayer.h"
#import "BridgeNode.h"
#import "Bridge4Node.h"
#import "HouseNode.h"
#import "BridgeColors.h"
#import "RiverNode.h"
#import "SubwayNode.h"
#import "Level.h"
#import "Undoable.h"

//#define PTM_RATIO 32.0

@interface LevelLayer() {
    bool _reportedWon;
    CGPoint _playerStart;
}
@property (readwrite, retain) NSMutableArray *undoStack;
@property (nonatomic, retain) PlayerNode *player;

/**
 * We use this emitter to show the confetti stars animation when you win
 * a level.
 */
@property (nonatomic, retain) CCParticleSystem *emitter;
@end

@implementation LevelLayer

+ (id)scene {
    
    CCScene *scene = [CCScene node];
    LevelLayer *layer = [LevelLayer node];
    layer.tag = LEVEL;
    [scene addChild:layer];
    return scene;
    
}

-(id)init {
    
    if( (self=[super initWithColor:ccc4(244, 243, 240, 255)] )) {
        
        director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
        
        _inCross = false;
        
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        bool doSleep = false;
        _world = new b2World(gravity);
        _world->SetAllowSleeping(doSleep);
        
        [self schedule:@selector(tick:)];
        
        _debugDraw = new GLESDebugDraw( PTM_RATIO );
        _world->SetDebugDraw(_debugDraw);
        
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        _debugDraw->SetFlags(flags);
        
        _contactListener = new MyContactListener();
        _world->SetContactListener(_contactListener);
        
        _spriteSheet = [[CCSpriteBatchNode batchNodeWithFile:@"bridgesprites.pvr.gz"
                         capacity:200] retain];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"bridgesprites.plist"];
        [self addChild:_spriteSheet];
        
        self.undoStack = [NSMutableArray arrayWithCapacity:20];
        _canVisit = true;
        
        _layerMgr = [[LayerMgr alloc] initWithSpriteSheet:_spriteSheet:_world];
        
        self.isTouchEnabled = YES;
    }
    return self;
    
}

/**
 * Read in the current level and load all of the nodes into the game scene.
 */
-(void)readLevel {
    CGSize s = [[CCDirector sharedDirector] winSize];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _layerMgr.tileSize = CGSizeMake((s.height - 75) / self.currentLevel.tileCount, s.height / self.currentLevel.tileCount);
    } else {
        _layerMgr.tileSize = CGSizeMake(s.height / self.currentLevel.tileCount, s.height / self.currentLevel.tileCount);
    }
    
    [self.currentLevel addSprites:_layerMgr:self.view];
    
    if (self.currentLevel.playerPos.x > -1) {
        [self spawnPlayer:self.currentLevel.playerPos.x :self.currentLevel.playerPos.y];
    }
    
    if ([self.currentLevel hasCoins]) {
        self.coinLbl.text = [NSString stringWithFormat:@"%i", self.currentLevel.coins];
        self.coinImage.hidden = NO;
    } else {
        self.coinLbl.text = @"";
        self.coinImage.hidden = YES;
    }
    
    [self updateAllBoxBodies];
}

/**
 * Reset the all of the moves in this level.
 */
-(void)reset {
    [_layerMgr removeAll];
    [self.currentLevel removeSprites: _layerMgr: self.view];
    [self.currentLevel unloadSprites];
    
    [self.undoStack removeAllObjects];
    _undoBtn.enabled = NO;
    
    [_player dealloc];
    _player = nil;
    
    _canVisit = true;
    
    _reportedWon = false;
}

-(void)setLevel:(Level*) level {
    if (self.currentLevel && [level.levelId isEqualToString:self.currentLevel.levelId] && !self.currentLevel.hasWon) {
        /*
         * If we already have that layer we just ignore it
         */
        return;
    }
    
    [self reset];
    
    self.currentLevel = level;
    
    /*
     * The first time we run we don't have the window dimensions
     * so we can't draw yet and we wait to add the level until the
     * first draw.  After that we have the dimensions so we can
     * just set the new level.
     */
    if (_hasInit) {
        [self readLevel];
    }
}

-(void)undo {
    if (self.undoStack.count == 0) {
        // There's nothing to undo
        return;
    }
    
    Undoable *undo = [self.undoStack objectAtIndex:self.undoStack.count - 1];
    
    [undo.node undo];
    [self.player updateColor:undo.color];
    self.player.player.position = undo.pos;
    if (self.currentLevel.hasCoins) {
        self.player.coins = undo.coins;
        self.coinLbl.text = [NSString stringWithFormat:@"%i", _player.coins];
    }
    _canVisit = undo.canVisit;
    
    [self.undoStack removeLastObject];
    
    if (self.undoStack.count == 0) {
        _undoBtn.enabled = NO;
    } else {
        _undoBtn.enabled = YES;
    }
    
}

-(void)refresh {
    [self reset];
    Level *level = self.currentLevel;
    self.currentLevel = nil;
    
    [self setLevel:level];
}

-(void)draw {
    
    [super draw];
    
    //ccDrawSolidRect( ccp(0, 0), ccp(s.width, s.height), ccc4f(255, 255, 255, 255) );
    
    if (!_hasInit) {
        /*
         * The director doesn't know the window width correctly
         * until we do the first draw so we need to delay adding
         * our objects which rely on knowing the dimensions of
         * the window until that happens.
         */
        [self readLevel];
        
        // [self addRivers];
        
        _hasInit = true;
    }
    
    if (DEBUG_DRAW) {
        _world->DrawDebugData();
        [self drawGrid];
    }
}

/**
 * Draw the tile grid.  This is used for debug drawing so we can see the 
 * grid and plan out level coordinates.
 */
-(void)drawGrid {
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    for (int i = 0; i < s.width; i += _layerMgr.tileSize.width) {
        if (i % 5 == 0) {
            ccDrawColor4F(0, 0, 128, 256);
        } else {
            ccDrawColor4F(0, 128, 128, 128);
        }
        ccDrawLine(ccp(i, 0), ccp(i, s.height));
    }
    
    for (int i = 0; i < s.height; i += _layerMgr.tileSize.height) {
        if (i % 5 == 0) {
            ccDrawColor4F(0, 0, 128, 256);
        } else {
            ccDrawColor4F(0, 128, 128, 128);
        }
        ccDrawLine(ccp(0, i), ccp(s.width, i));
    }
}

/**
 * This method finds all of the box bodies and updates them to match the positions
 * of all the sprites in the game scene.
 */
-(void)updateAllBoxBodies {
    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();
            
            b2Vec2 b2Position = b2Vec2(sprite.position.x/PTM_RATIO,
                                       sprite.position.y/PTM_RATIO);
            float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
            
            b->SetTransform(b2Position, b2Angle);
        }
    }
}


-(void)tick:(ccTime)dt {
    if (_inCross) {
        /*
         * We get a lot of collisions when crossing a bridge
         * and we just want to ignore them until we're done.
         */
        return;
    }
    
    _world->Step(dt, 10, 10);
    
    /*
     * We need to update the box for each sprite on each frame
     * so we can still detect collisions, but if we update all 
     * of them the player moves really slowly on more complex 
     * levels.  
     *
     * The solution is to only update the player box since all of
     * the other objects are stationary and don't need an update.
     */    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();
            
            if (sprite != self.player.player) {
                continue;
            }
            
            b2Vec2 b2Position = b2Vec2(sprite.position.x/PTM_RATIO,
                                       sprite.position.y/PTM_RATIO);
            float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
            
            b->SetTransform(b2Position, b2Angle);
            break;
        }
    }
    
    std::vector<MyContact>::iterator pos;
    for(pos = _contactListener->_contacts.begin();
        pos != _contactListener->_contacts.end(); ++pos) {
        MyContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
            
            if (spriteA.tag == RIVER && spriteB.tag == PLAYER) {
                [self bumpObject:spriteB:spriteA];
            } else if (spriteA.tag == PLAYER && spriteB.tag == RIVER) {
                [self bumpObject:spriteA:spriteB];
            } else if (spriteA.tag == BRIDGE && spriteB.tag == PLAYER) {
                [self crossBridge:spriteB:spriteA];
            } else if (spriteA.tag == PLAYER && spriteB.tag == BRIDGE) {
                [self crossBridge:spriteA:spriteB];
            } else if (spriteA.tag == BRIDGE4 && spriteB.tag == PLAYER) {
                [self crossBridge4:spriteB:spriteA];
            } else if (spriteA.tag == PLAYER && spriteB.tag == BRIDGE4) {
                [self crossBridge4:spriteA:spriteB];
            } else if (spriteA.tag == HOUSE && spriteB.tag == PLAYER) {
                [self visitHouse:spriteB:spriteA];
            } else if (spriteA.tag == PLAYER && spriteB.tag == HOUSE) {
                [self visitHouse:spriteA:spriteB];
            } else if (spriteA.tag == SUBWAY && spriteB.tag == PLAYER) {
                [self rideSubway:spriteB:spriteA];
            } else if (spriteA.tag == SUBWAY && spriteB.tag == HOUSE) {
                [self rideSubway:spriteA:spriteB];
            }
        }
    }
}

-(BridgeNode*)findBridge:(CCSprite*) bridge {
    for (BridgeNode *n in self.currentLevel.bridges) {
        if (n.bridge == bridge) {
            return n;
        }
    }
    
    return nil;
}

-(SubwayNode*)findSubway:(CCSprite*) subway {
    for (SubwayNode *n in self.currentLevel.subways) {
        if (n.subway1 == subway ||
            n.subway2 == subway) {
            return n;
        }
    }
    
    return nil;
}

-(Bridge4Node*)findBridge4:(CCSprite*) bridge {
    for (Bridge4Node *n in self.currentLevel.bridge4s) {
        if (n.bridge == bridge) {
            return n;
        }
    }
    
    return nil;
}

-(HouseNode*)findHouse:(CCSprite*) house {
    for (HouseNode *n in self.currentLevel.houses) {
        if (n.house == house) {
            return n;
        }
    }
    
    return nil;
}

-(void)visitHouse:(CCSprite *) player:(CCSprite*) house {
    /*
     * The player has run into a house.  We need to visit the house
     * if the player is the right color and bump it if it isn't
     */
    HouseNode *node = [self findHouse:house];
    
    if (node.isVisited) {
        /*
         * If the house is visited then there's no reason to bounce
         * off of it.
         */
        return;
    }
    
    if ([self canVisit] && ![node isVisited] && [self colorMatches:node]) {
        [self.undoStack addObject: [[Undoable alloc] initWithPosAndNode:_prevPlayerPos :node: _player.color: _player.coins: _canVisit]];
        _undoBtn.enabled = YES;
        if (node.coins > 0) {
            _player.coins++;
            self.coinLbl.text = [NSString stringWithFormat:@"%i", _player.coins];
        }
        [node visit];
        _canVisit = false;
    } else {
        [self showNoTapSprite:self.player.player.position];
    }
    
    [self bumpObject:player:house];
    
}

-(bool)colorMatches: (HouseNode*) node {
    if (node.color == cNone || _player.color == node.color) {
        return true;
    } else {
        [self.controller showMessage:@"Change color to visit this house"];
        return false;
    }
}

-(bool)canVisit {
    if (!self.currentLevel.hasCoins || _canVisit) {
        return true;
    } else {
        [self.controller showMessage:@"Visit another island first"];
        return false;
    }
}

-(void)rideSubway:(CCSprite *) player:(CCSprite*) subway {
    /*
     * The player has run into a subway.  We need to ride the subway
     * if the player is the right color and bump it if it isn't
     */
    SubwayNode *node = [self findSubway:subway];
    
    if (_player.coins > 0 &&
        (node.color == cNone || _player.color == node.color)) {
        [self.undoStack addObject: [[Undoable alloc] initWithPosAndNode:_prevPlayerPos :node: _player.color: _player.coins: _canVisit]];
        _undoBtn.enabled = YES;
        
        _player.coins--;
        self.coinLbl.text = [NSString stringWithFormat:@"%i", _player.coins];
        
        CCSprite *exit = [node ride:subway];
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        _playerStart = ccp(s.width / 2, s.height / 2);
        
        _player.player.position = ccp(exit.position.x, exit.position.y);
        [self bumpObject:player:exit];
        _canVisit = true;
    } else {
        if (_player.coins == 0) {
            [self.controller showMessage:@"You need more coins to ride"];
        } else {
            [self.controller showMessage:@"Change color to ride this subway"];
        }
        [self showNoTapSprite:self.player.player.position];
        [self bumpObject:player:subway];
        
    }
    
}

-(void)crossBridge:(CCSprite *) player:(CCSprite*) bridge {
    /*
     * The player has run into a bridge.  We need to cross the bridge
     * if it hasn't been crossed yet and not if it has.
     */
    BridgeNode *node = [self findBridge:bridge];
    
    if ([node isCrossed]) {
        [self showNoTapSprite:self.player.player.position];
        [self bumpObject:player:bridge];
        [self.controller showMessage:@"You already crossed this bridge"];
    } else if (node.coins > 0 && _player.coins < 1) {
        [self showNoTapSprite:self.player.player.position];
        [self bumpObject:player:bridge];
        [self.controller showMessage:@"You need more coins to cross"];
    } else {
        _inCross = true;
        [self doCross:player:node:bridge];
    }
    
}

-(void)crossBridge4:(CCSprite *) player:(CCSprite*) bridge {
    
    if (_inBridge) {
        return;
    }
    /*
     * The player has run into a 4-way bridge.  We need to cross the bridge
     * if it hasn't been crossed yet and not if it has.
     */
    Bridge4Node *node = [self findBridge4:bridge];
    
    if ([node isCrossed]) {
        [self bumpObject:player:bridge];
    } else {
        _inCross = true;
        _inBridge = true;
        [self doCross4:player:node:bridge];
    }
    
}

-(void)finishCross4: (CGPoint) touch {
    int exitDir = -1;
    
    CGPoint p0 = _player.player.position;
    CGPoint p1 = touch;
    CGPoint pnormal = ccpSub(p1, p0);
    CGFloat angle = CGPointToDegree(pnormal);
    
    if (angle > 45 && angle < 135) {
        exitDir = dRight;
    } else if ((angle > 135 && angle < 180) || (angle < -135 && angle > -180)) {
        exitDir = dDown;
    } else if (angle < -45 && angle > -135) {
        exitDir = dLeft;
    } else {
        exitDir = dUp;
    }
    
    if (exitDir == _bridgeEntry) {
        /*
         * You can't exit the bridge from the same direction you enter it
         */
        return;
    }
    
    CGPoint location;
    
    //    printf("current bridge (%f, %f)\n", _currentBridge.bridge.position.x, _currentBridge.bridge.position.y);
    
    if (exitDir == dRight) {
        location = ccp(_currentBridge.bridge.position.x + (_currentBridge.bridge.contentSize.width / 2) + (_player.player.contentSize.width), _currentBridge.bridge.position.y);
    } else if (exitDir == dLeft) {
        location = ccp((_currentBridge.bridge.position.x -(_currentBridge.bridge.contentSize.width / 2)) -(_player.player.contentSize.width), _currentBridge.bridge.position.y);
    } else if (exitDir == dUp) {
        location = ccp(_currentBridge.bridge.position.x, _currentBridge.bridge.position.y + (_currentBridge.bridge.contentSize.height / 2) + (_player.player.contentSize.height));
    } else if (exitDir == dDown) {
        location = ccp(_currentBridge.bridge.position.x, (_currentBridge.bridge.position.y -(_currentBridge.bridge.contentSize.height / 2)) -(_player.player.contentSize.height));
    }
    
    [_player moveTo: location:true];
    
    [_currentBridge cross];
    _canVisit = true;
    _currentBridge = nil;
    _inBridge = false;
    
    [self hasWon];
}

CGFloat CGPointToDegree(CGPoint point) {
    CGFloat bearingRadians = atan2f(point.x, point.y);
    CGFloat bearingDegrees = bearingRadians * (180. / M_PI);
    return bearingDegrees;
}

-(void)doCross4:(CCSprite *) player:(Bridge4Node*) bridge:(CCSprite*) object {
    CCActionManager *mgr = [player actionManager];
    [mgr pauseTarget:player];
    _inMove = true;
    
    /*
     * When the player hits a 4-way bridge we take them to the middle of the bridge
     * and make them tap again to decide which way they'll exit the bridge.
     */
    CGPoint location = ccp(bridge.bridge.position.x, bridge.bridge.position.y);
    
    int padding = bridge.bridge.contentSize.width / 2;
    
    if (player.position.x < bridge.bridge.position.x - padding) {
        _bridgeEntry = dLeft;
    } else if (player.position.x > bridge.bridge.position.x + padding) {
        _bridgeEntry = dRight;
    } else if (player.position.y < bridge.bridge.position.y - padding) {
        _bridgeEntry = dDown;
    } else if (player.position.y > bridge.bridge.position.y - padding) {
        _bridgeEntry = dUp;
    }
    
    _currentBridge = bridge;
    
    
    [mgr removeAllActionsFromTarget:player];
    [mgr resumeTarget:player];
    
    [self.undoStack addObject: [[Undoable alloc] initWithPosAndNode:_prevPlayerPos :bridge: _player.color: _player.coins: _canVisit]];
    _undoBtn.enabled = YES;
    
    [_player moveTo: ccp(location.x, location.y):true];
    
    [bridge enterBridge:_bridgeEntry];
    
    if (bridge.color != cNone) {
        [_player updateColor:bridge.color];
    }
}

/**
 * Handle the player crossing a bridge.
 *
 * @param player the player sprite
 * @param bridge the bridge node the player is crossing
 * @param object the sprite corresponding to the bridge the player is crossing
 */
-(void)doCross:(CCSprite*) player:(BridgeNode*) bridge:(CCSprite*) object {
    CCActionManager *mgr = [player actionManager];
    [mgr pauseTarget:player];
    _inMove = true;
    
    CGPoint location;
    
    int padding = bridge.bridge.contentSize.width / 2;
    
    //    printf("player (%f, %f)\n", player.position.x, player.position.y);
    //    printf("bridge (%f, %f)\n", object.position.x, object.position.y);
    //    printf("vertical: %i\n", bridge.vertical);
    
    if (bridge.vertical) {
        if (_playerStart.y + player.contentSize.height < object.position.y + padding) {
            // Then the player is below the bridge
            if (bridge.direction != dUp && bridge.direction != dNone) {
                _inMove = false;
                [self.controller showMessage:@"Cross this bridge from the other side"];
                [self bumpObject:player :bridge.bridge];
                return;
            }
            int x = (object.position.x + (object.contentSize.width / 2)) - (player.contentSize.width / 2);
            location = ccp(x, object.position.y + object.contentSize.height + 5);
        } else if (_playerStart.y > (object.position.y + object.contentSize.height) - padding) {
            // Then the player is above the bridge
            if (bridge.direction != dDown && bridge.direction != dNone) {
                _inMove = false;
                [self.controller showMessage:@"Cross this bridge from the other side"];
                [self bumpObject:player :bridge.bridge];
                return;
            }
            int x = (object.position.x + (object.contentSize.width / 2)) - (player.contentSize.width / 2);
            location = ccp(x, (object.position.y) - (player.contentSize.height + 5));
        }
    } else {
        if (_playerStart.x > (object.position.x + object.contentSize.width) - padding) {
            // Then the player is to the right of the bridge
            if (bridge.direction != dLeft && bridge.direction != dNone) {
                _inMove = false;
                [self.controller showMessage:@"Cross this bridge from the other side"];
                [self bumpObject:player: bridge.bridge];
                return;
            }
            int y = (object.position.y + (object.contentSize.height / 2)) -
            (player.contentSize.height / 2);
            location = ccp((object.position.x - 5) -(player.contentSize.width), y);
        } else if (_playerStart.x + player.contentSize.width < object.position.x + padding) {
            // Then the player is to the left of the bridge
            if (bridge.direction != dRight && bridge.direction != dNone) {
                _inMove = false;
                [self.controller showMessage:@"Cross this bridge from the other side"];
                [self bumpObject:player :bridge.bridge];
                return;
            }
            int y = (object.position.y + (object.contentSize.height / 2)) -
            (player.contentSize.height / 2);
            location = ccp(object.position.x + 5 + object.contentSize.width, y);
        }
    }
    
    [mgr removeAllActionsFromTarget:player];
    [mgr resumeTarget:player];
    
    
    [self.undoStack addObject: [[Undoable alloc] initWithPosAndNode:_prevPlayerPos :bridge: _player.color: _player.coins: _canVisit]];
    _undoBtn.enabled = YES;
    
    [_player moveTo: ccp(location.x, location.y):true];
    
    if (bridge.coins > 0) {
        _player.coins--;
        self.coinLbl.text = [NSString stringWithFormat:@"%i", _player.coins];
    }
    [bridge cross];
    _canVisit = true;
    
    if (bridge.color != cNone) {
        [_player updateColor:bridge.color];
    }
    
    [self hasWon];
}

/**
 * The player bumped into a river or crossed bridge and is now
 * in the middle of an animation overlapping a river.  We need
 * to stop the animation and move the player back off the river
 * so they aren't overlapping anymore.
 *
 * This method happens as the result of a colision.  I was hoping
 * that we'd be notified as soon as the colission happened, but
 * instead the notification happens a variable time after the
 * colision and while the objects are intersecting.  That means
 * we can't use the position of the objects to determine their
 * direction and we have to use the original starting position instead.
 */
-(void)bumpObject:(CCSprite *) player:(CCSprite*) object {
    
    
    if (_inMove) {
        return;
    }
    
    _inMove = true;
    
    CCActionManager *mgr = [player actionManager];
    [mgr pauseTarget:player];
    
    float step = object.contentSize.width * 1.6;
    
    if (object.tag == SUBWAY) {
        /*
         * We jump right into the middle of subways so they
         * need a larger space to make sure we move off of 
         * the sprite.
         */
        step = object.contentSize.width * 1.8;
    }
    
    _player.player.position = [self pointOnLine: _playerStart: _player.player.position: step];
    
    [_player playerMoveEnded];
    
    [mgr removeAllActionsFromTarget:player];
    [mgr resumeTarget:player];
    
    [self hasWon];
    
}

/**
 * Given the line defined by two points (p1 and p2) this method finds
 * the point along that line which is the specified distance away from
 * the second point.
 *
 * @param p1 the first point defining the line
 * @param p2 the second point defining the line
 * @param distance the distance along the line to travel
 */
-(CGPoint)pointOnLine: (CGPoint) p1: (CGPoint) p2: (int) distance {
    double rads = atan2(p2.y - p1.y, p2.x - p1.x);
    
    double x3 = p2.x - distance * cos(rads);
    double y3 = p2.y - distance * sin(rads);
    
    if ([LayerMgr distanceBetweenTwoPoints:p1 :p2] == 0) {
        return p1;
    } else if ([LayerMgr distanceBetweenTwoPoints:p1 :p2] < distance) {
        return p1;
    }
    
    if ([LayerMgr distanceBetweenTwoPoints:p1 :p2] < _layerMgr.tileSize.width) {
        /*
         * If the player is really close to the object they bumped into
         * then bumping them back along the line they approached from 
         * doesn't move them far enough away from the object and they
         * end up on top of the object where they get stuck.  
         *
         * In that case we need to move them back a little bit more so
         * they end up off the object.
         */
        x3 = p2.x - ((distance * cos(rads)) * 1.5);
        y3 = p2.y - ((distance * sin(rads)) * 1.5);
    }
    
    return ccp(x3, y3);
}

-(void) hasWon {
    if (!_reportedWon && [self.currentLevel hasWon]) {
        _reportedWon = true;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setBool:TRUE forKey:[NSString stringWithFormat:@"%@-won", self.currentLevel.levelId]];
        [defaults synchronize];
        
        [self showConfetti:self.player.player.position.x:self.player.player.position.y];
    }    
}

/**
 * When the player wins a level we show a small animation of stars to celebrate.
 * We show this animation with a particle emitter.
 */
-(void) showConfetti: (float) x: (float) y
{
    self.emitter = [[CCParticleSnow alloc] init];
    [self.emitter setScaleX:0.5];
    [self.emitter setScaleY:0.5];
    
    [self.emitter resetSystem];
    self.emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"confetti.png"];
    
    self.emitter.duration = 2;
    
    // gravity
    self.emitter.gravity = ccp(self.player.player.position.x, 90);
    
    // angle
    self.emitter.angle = 90;
    self.emitter.angleVar = 360;
    
    // speed of particles
    self.emitter.speed = 160;
    self.emitter.speedVar = 20;
    
    // radial
    self.emitter.radialAccel = -120;
    self.emitter.radialAccelVar = 120;
    
    // tagential
    self.emitter.tangentialAccel = 30;
    self.emitter.tangentialAccelVar = 90;
    
    // life of particles
    self.emitter.life = 1;
    self.emitter.lifeVar = 4;
    
    // spin of particles
    self.emitter.startSpin = 15;
    self.emitter.startSpinVar = 5;
    self.emitter.endSpin = 15;
    self.emitter.endSpinVar = 5;
    
    // color of particles
    ccColor4F startColor = {243.0f, 162.f, 162.0f, 1.0f};
    self.emitter.startColor = startColor;
    ccColor4F startColorVar = {74.0f, 204.0f, 236.0f, 1.0f};
    self.emitter.startColorVar = startColorVar;
    ccColor4F endColor = {243.0f, 27.0f, 38.0f, 1.0f};
    self.emitter.endColor = endColor;
    ccColor4F endColorVar = {255.0f, 195.0f, 16.0f, 1.0f};
    self.emitter.endColorVar = endColorVar;
    
    
    // size, in pixels
    self.emitter.startSize = 50.0f;
    self.emitter.startSizeVar = 5.0f;
    self.emitter.endSize = kParticleStartSizeEqualToEndSize;
    // emits per second
    self.emitter.totalParticles = 350;
    self.emitter.emissionRate = self.emitter.totalParticles/self.emitter.life;
    
    self.emitter.posVar = ccp(x + 20, y - 20);
    
    self.emitter.blendAdditive = NO;
    
    self.emitter.position = ccp(x,y);
    [self addChild: self.emitter z:10];
    self.emitter.autoRemoveOnFinish = YES;
    
    [self scheduleOnce:@selector(doWon) delay:2];
}

-(void) doWon {
    [self removeChild:self.emitter cleanup:YES];
    [self.emitter release];
    self.emitter = nil;
    [self.controller won];
}

-(void)spawnPlayer:(int) x: (int) y {
    
    _player = [[PlayerNode alloc] initWithColor:cBlack:_layerMgr];
    _player.player.position = ccp(x, y);
    
    if ([self.currentLevel hasCoins]) {
        self.player.coins = self.currentLevel.coins;
    }
}

/**
 * Determine if the point is in an object.  Returns true if the point is inside
 * an object and false otherwise.
 */
-(bool)inObject:(CGPoint) p {
    for (BridgeNode *n in self.currentLevel.bridges) {
        if (CGRectContainsPoint([n.bridge boundingBox], p)) {
            return true;
        }
    }
    
    for (Bridge4Node *n in self.currentLevel.bridge4s) {
        if (CGRectContainsPoint([n.bridge boundingBox], p)) {
            return true;
        }
    }
    
    for (RiverNode *n in self.currentLevel.rivers) {
        for (CCSprite *r in n.rivers) {
            if (CGRectContainsPoint([r boundingBox], p)) {
                return true;
            }
        }
    }
    
    for (HouseNode *h in self.currentLevel.houses) {
        if (CGRectContainsPoint([h.house boundingBox], p)) {
            return true;
        }
    }
    
    for (SubwayNode *s in self.currentLevel.subways) {
        if (CGRectContainsPoint([s.subway1 boundingBox], p) ||
            CGRectContainsPoint([s.subway2 boundingBox], p)) {
            return true;
        }
    }
    
    return false;
    
}

/**
 * The user taps to place the player at the start of many of the levels.  If the
 * user tries to place the player on an existing object like a river or a bridge
 * then we show the X icon with a little pulse animation.
 */
-(void)showNoTapSprite: (CGPoint) p {
    CCSprite *x = [CCSprite spriteWithSpriteFrameName:@"x.png"];
    [_layerMgr addChildToSheet:x];
    
    x.position = p;
    
    
    id scaleUpAction =  [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.25 scaleX:1.25 scaleY:1.25] rate:0.5];
    id scaleDownAction = [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.25 scaleX:0.75 scaleY:0.75] rate:0.5];
    CCSequence *scaleSeq = [CCSequence actions:scaleUpAction, scaleDownAction, [CCHide action], nil];
    
    [x runAction:scaleSeq];
    
    [self.controller showMessage:@"You have to start in an open space"];
}

-(void)ccTouchesEnded:(NSSet*) touches withEvent:(UIEvent*) event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    _inMove = false;
    
    if (_inBridge) {
        [self finishCross4:location];
        return;
    }
    
    if (_player == nil) {
        if (![self inObject:location]) {
            [self spawnPlayer:location.x: location.y];
        } else {
            [self showNoTapSprite:location];
        }
    } else {
        _inCross = false;
        _prevPlayerPos = _player.player.position;
        
        _playerStart = _player.player.position;
        [_player moveTo:location];
    }
    
}

-(void)dealloc {
    
    delete _world;
    delete _debugDraw;
    
    delete _contactListener;
    [_spriteSheet release];
    [_player dealloc];
    
    [_undoStack release];
    _undoStack = nil;

    [self.undoBtn release];
    [self.coinLbl release];
    [self.coinImage release];
    [self.view release];
    [self.controller release];
    
    [super dealloc];
}

@end