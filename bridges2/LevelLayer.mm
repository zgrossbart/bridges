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
#import "Level.h"
#import "Undoable.h"

//#define PTM_RATIO 32.0

@interface LevelLayer() {
    bool _reportedWon;
    CGPoint _playerStart;
}
@property (readwrite, retain) NSMutableArray *undoStack;
@property (nonatomic, retain) PlayerNode *player;
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
    
    if( (self=[super initWithColor:ccc4(244,243,240,255)] )) {
        
        director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
        
        _inCross = false;
        
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        bool doSleep = false;
        _world = new b2World(gravity);
        _world->SetAllowSleeping(doSleep);
        
        [self schedule:@selector(tick:)];
        
        // Enable debug draw
        _debugDraw = new GLESDebugDraw( PTM_RATIO );
        _world->SetDebugDraw(_debugDraw);
        
        uint32 flags = 0;
        flags += b2Draw::e_shapeBit;
        _debugDraw->SetFlags(flags);
        
        // Create contact listener
        _contactListener = new MyContactListener();
        _world->SetContactListener(_contactListener);
        
        // Create our sprite sheet and frame cache
        _spriteSheet = [[CCSpriteBatchNode batchNodeWithFile:@"bridgesprites.pvr.gz"
                                                    capacity:150] retain];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"bridgesprites.plist"];
        [self addChild:_spriteSheet];
        
        self.undoStack = [NSMutableArray arrayWithCapacity:10];
        _canVisit = true;
        
        _layerMgr = [[LayerMgr alloc] initWithSpriteSheet:_spriteSheet:_world];
        
        //        [self spawnPlayer];
        
        self.isTouchEnabled = YES;
    }
    return self;
    
}

-(void)readLevel {
    //   [level.rivers makeObjectsPerformSelector:@selector(addSprite:)];
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    _layerMgr.tileSize = CGSizeMake(s.height / self.currentLevel.tileCount, s.height / self.currentLevel.tileCount);
    
    [self.currentLevel addSprites:_layerMgr:self.view];
    
    if (self.currentLevel.playerPos.x > -1) {
        [self spawnPlayer:self.currentLevel.playerPos.x :self.currentLevel.playerPos.y];
    }
    
    if ([self.currentLevel hasCoins]) {
        self.coinLbl.text = [NSString stringWithFormat:@"%i", 0];
        self.coinImage.hidden = NO;
    } else {
        self.coinLbl.text = @"";
        self.coinImage.hidden = YES;
    }
    
    [self updateAllBoxBodies];
}

-(void)reset {
    [_layerMgr removeAll];
    [self.currentLevel removeSprites: _layerMgr: self.view];
    
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
    
    
    //    std::vector<b2Body *>toDestroy;
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
    
    if (_canVisit && ![node isVisited]) {
        if (node.color == cNone || _player.color == node.color) {
            [self.undoStack addObject: [[Undoable alloc] initWithPosAndNode:_prevPlayerPos :node: _player.color: _player.coins]];
            _undoBtn.enabled = YES;
            if (node.coins > 0) {
                _player.coins++;
                self.coinLbl.text = [NSString stringWithFormat:@"%i", _player.coins];
            }
            [node visit];
            _canVisit = false;
        }
    }
    
    [self bumpObject:player:house];
    
}

-(void)crossBridge:(CCSprite *) player:(CCSprite*) bridge {
    /*
     * The player has run into a bridge.  We need to cross the bridge
     * if it hasn't been crossed yet and not if it has.
     */
    BridgeNode *node = [self findBridge:bridge];
    
    if ([node isCrossed] || (node.coins > 0 && _player.coins < 1)) {
        [self bumpObject:player:bridge];
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
    
    //    printf("Moving to (%f, %f)\n", location.x, location.y);
    //    location.y += 5;
    //    _player.position = location;
    
    [self.undoStack addObject: [[Undoable alloc] initWithPosAndNode:_prevPlayerPos :bridge: _player.color: _player.coins]];
    _undoBtn.enabled = YES;
    
    [_player moveTo: ccp(location.x, location.y):true];
    
    [bridge enterBridge:_bridgeEntry];
    
    if (bridge.color != cNone) {
        [_player updateColor:bridge.color];
    }
}

-(void)doCross:(CCSprite *) player:(BridgeNode*) bridge:(CCSprite*) object {
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
                [self bumpObject:player :bridge.bridge];
                return;
            }
            int x = (object.position.x + (object.contentSize.width / 3)) -
            (player.contentSize.width);
            location = ccp(x, object.position.y + object.contentSize.height + 5);
        } else if (_playerStart.y > (object.position.y + object.contentSize.height) - padding) {
            // Then the player is above the bridge
            if (bridge.direction != dDown && bridge.direction != dNone) {
                _inMove = false;
                [self bumpObject:player :bridge.bridge];
                return;
            }
            int x = (object.position.x + (object.contentSize.width / 3)) -
            (player.contentSize.width);
            location = ccp(x, (object.position.y - 5) -(player.contentSize.height * 2));
        }
    } else {
        if (_playerStart.x > (object.position.x + object.contentSize.width) - padding) {
            // Then the player is to the right of the bridge
            if (bridge.direction != dLeft && bridge.direction != dNone) {
                _inMove = false;
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
                [self bumpObject:player :bridge.bridge];
                return;
            }
            int y = (object.position.y + (object.contentSize.height / 2)) -
            (player.contentSize.height / 2);
            location = ccp(object.position.x + 5 + object.contentSize.width, y);
        }
    }
    
    /*if (location == NULL) {
     printf("player (%f, %f)\n", player.position.x, player.position.y);
     printf("river (%f, %f)\n", object.position.x, object.position.y);
     printf("This should never happen\n");
     }*/
    
    [mgr removeAllActionsFromTarget:player];
    [mgr resumeTarget:player];
    
    //    printf("Moving to (%f, %f)\n", location.x, location.y);
    //    location.y += 5;
    //    _player.position = location;
    
    [self.undoStack addObject: [[Undoable alloc] initWithPosAndNode:_prevPlayerPos :bridge: _player.color: _player.coins]];
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
    
    _player.player.position = [self pointOnLine: _playerStart: _player.player.position: _layerMgr.tileSize.width * 1.5];
    
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
        
        /*
         * TODO - We should do something cute here when
         * you win a level.  Right now the you won screen
         * comes a little too fast.
         */
        
        [self.controller won];
    }
    
}

-(void)spawnPlayer:(int) x: (int) y {
    
    _player = [[PlayerNode alloc] initWithColor:cBlack:_layerMgr];
    _player.player.position = ccp(x, y);
}

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
    
    return false;
    
}

-(void)showNoTapSprite: (CGPoint) p {
    CCSprite *x = [CCSprite spriteWithSpriteFrameName:@"x.png"];
    [_layerMgr addChildToSheet:x];
    
    x.position = p;
    
    
    id scaleUpAction =  [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.25 scaleX:1.25 scaleY:1.25] rate:0.5];
    id scaleDownAction = [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.25 scaleX:0.75 scaleY:0.75] rate:0.5];
    CCSequence *scaleSeq = [CCSequence actions:scaleUpAction, scaleDownAction, [CCHide action], nil];
    
    [x runAction:scaleSeq];
}

-(void)ccTouchesEnded:(NSSet*) touches withEvent:(UIEvent*) event {
    
    // Choose one of the touches to work with
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
        //        [_player.player runAction:
        //         [CCMoveTo actionWithDuration:distance/velocity position:ccp(location.x,location.y)]];
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
    
    //    [self.currentLevel dealloc];
    
    [super dealloc];
}

@end