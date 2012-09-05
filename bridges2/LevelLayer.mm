#import "LevelLayer.h"
#import "BridgeNode.h"
#import "Bridge4Node.h"
#import "HouseNode.h"
#import "BridgeColors.h"
#import "Level.h"
#import "Undoable.h"

//#define PTM_RATIO 32.0

@interface LevelLayer()
    @property (readwrite) NSMutableArray *undoStack;
@end

@implementation LevelLayer


+ (id)scene {
    
    CCScene *scene = [CCScene node];
    LevelLayer *layer = [LevelLayer node];
    layer.tag = LEVEL;
    [scene addChild:layer];
    return scene;
    
}


- (id)init {
    
    if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
        
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
        _spriteSheet = [[CCSpriteBatchNode batchNodeWithFile:@"octosprite.png"
                                                    capacity:2] retain];
        [[CCSpriteFrameCache sharedSpriteFrameCache]
         addSpriteFramesWithFile:@"octosprite.plist"];
        [self addChild:_spriteSheet];
        
        self.undoStack = [[NSMutableArray alloc] init];
        
        _layerMgr = [[LayerMgr alloc] initWithSpriteSheet:_spriteSheet:_world];
        
        //        [self spawnPlayer];
        
        self.isTouchEnabled = YES;
    }
    return self;
    
}

-(void)readLevel {    
 //   [level.rivers makeObjectsPerformSelector:@selector(addSprite:)];
    
    [self.currentLevel addSprites:_layerMgr];
    
    for (UIButton *l in self.currentLevel.labels) {
        [self.view addSubview:l];
    }
    
    if (self.currentLevel.playerPos.x > -1) {
        [self spawnPlayer:self.currentLevel.playerPos.x :self.currentLevel.playerPos.y];
    }
    
    
    //[level dealloc];
}

-(void)reset {
    [_layerMgr removeAll];
    [self.undoStack removeAllObjects];
    UIImage *undoD = [UIImage imageNamed:@"left_arrow_d.png"];
    [_undoBtn setImage:undoD forState:UIControlStateNormal];
    
    if (self.currentLevel) {
        for (UIButton *l in self.currentLevel.labels) {
            [l removeFromSuperview];
        }
    }
    
    [_player dealloc];
    _player = nil;
}

-(void)setLevel:(Level*) level {
    if (self.currentLevel && [level.levelId isEqualToString:self.currentLevel.levelId]) {
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
    self.player.player.position = undo.pos;
    
    [self.undoStack removeLastObject];
    
    if (self.undoStack.count == 0) {
        UIImage *undoD = [UIImage imageNamed:@"left_arrow_d.png"];
        [_undoBtn setImage:undoD forState:UIControlStateNormal];
    } else {
        UIImage *undoD = [UIImage imageNamed:@"left_arrow.png"];
        [_undoBtn setImage:undoD forState:UIControlStateNormal];
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
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    ccDrawSolidRect( ccp(0, 0), ccp(s.width, s.height), ccc4f(255, 255, 255, 255) );
    
    if (!_hasInit) {
        /*
         * The director doesn't know the window width correctly
         * until we do the first draw so we need to delay adding
         * our objects which rely on knowing the dimensions of
         * the window until that happens.
         */
        _layerMgr.tileSize = CGSizeMake(s.height / 28, s.height / 28);
        [self readLevel];
       // [self addRivers];
        
        _hasInit = true;
    }
    
     _world->DrawDebugData();
}


- (void)tick:(ccTime)dt {
    if (_inCross) {
        /*
         * We get a lot of collisions when crossing a bridge
         * and we just want to ignore them until we're done.
         */
        return;
    }
    
    _world->Step(dt, 10, 10);
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *)b->GetUserData();
            
            b2Vec2 b2Position = b2Vec2(sprite.position.x/PTM_RATIO,
                                       sprite.position.y/PTM_RATIO);
            float32 b2Angle = -1 * CC_DEGREES_TO_RADIANS(sprite.rotation);
            
            b->SetTransform(b2Position, b2Angle);
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

- (void)visitHouse:(CCSprite *) player:(CCSprite*) house {
    /*
     * The player has run into a house.  We need to visit the house
     * if the player is the right color and bump it if it isn't
     */
    HouseNode *node = [self findHouse:house];
    
    if (![node isVisited]) {
        if (node.color == NONE || _player.color == node.color) {
            [self.undoStack addObject: [[Undoable alloc] initWithPosAndNode:_prevPlayerPos :node: _player.color]];
            UIImage *undoD = [UIImage imageNamed:@"left_arrow.png"];
            [_undoBtn setImage:undoD forState:UIControlStateNormal];
            [node visit];
        }
    }
    
    [self bumpObject:player:house];
    
}

- (void)crossBridge:(CCSprite *) player:(CCSprite*) bridge {
    /*
     * The player has run into a bridge.  We need to cross the bridge
     * if it hasn't been crossed yet and not if it has.
     */
    BridgeNode *node = [self findBridge:bridge];
    
    if ([node isCrossed]) {
        [self bumpObject:player:bridge];
    } else {
        _inCross = true;
        [self doCross:player:node:bridge];
    }
    
}

- (void)crossBridge4:(CCSprite *) player:(CCSprite*) bridge {
    
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

- (void)finishCross4: (CGPoint) touch {
    int exitDir = -1;
    
    CGPoint p0 = _player.player.position;
    CGPoint p1 = touch;
    CGPoint pnormal = ccpSub(p1, p0);
    CGFloat angle = CGPointToDegree(pnormal);
    
    if (angle > 45 && angle < 135) {
        exitDir = RIGHT;
    } else if ((angle > 135 && angle < 180) || (angle < -135 && angle > -180)) {
        exitDir = DOWN;
    } else if (angle < -45 && angle > -135) {
        exitDir = LEFT;
    } else {
        exitDir = UP;
    }
    
    if (exitDir == _bridgeEntry) {
        /*
         * You can't exit the bridge from the same direction you enter it
         */
        return;
    }
        
    CGPoint location;
    
//    printf("current bridge (%f, %f)\n", _currentBridge.bridge.position.x, _currentBridge.bridge.position.y);
    
    if (exitDir == RIGHT) {
        location = ccp(_currentBridge.bridge.position.x + (_currentBridge.bridge.contentSize.width / 2) + (_player.player.contentSize.width), _currentBridge.bridge.position.y);
    } else if (exitDir == LEFT) {
        location = ccp((_currentBridge.bridge.position.x - (_currentBridge.bridge.contentSize.width / 2)) - (_player.player.contentSize.width), _currentBridge.bridge.position.y);
    } else if (exitDir == UP) {
        location = ccp(_currentBridge.bridge.position.x, _currentBridge.bridge.position.y + (_currentBridge.bridge.contentSize.height / 2) + (_player.player.contentSize.height));
    } else if (exitDir == DOWN) {
        location = ccp(_currentBridge.bridge.position.x, (_currentBridge.bridge.position.y - (_currentBridge.bridge.contentSize.height / 2)) - (_player.player.contentSize.height));
    }
    
    [_player moveTo: location:true];
    
    [_currentBridge cross];
    _currentBridge = nil;
    _inBridge = false;
    
    [self hasWon];
}

CGFloat CGPointToDegree(CGPoint point) {
    CGFloat bearingRadians = atan2f(point.x, point.y);
    CGFloat bearingDegrees = bearingRadians * (180. / M_PI);
    return bearingDegrees;
}

- (void)doCross4:(CCSprite *) player:(Bridge4Node*) bridge:(CCSprite*) object {
    CCActionManager *mgr = [player actionManager];
    [mgr pauseTarget:player];
    
    /*
     * When the player hits a 4-way bridge we take them to the middle of the bridge
     * and make them tap again to decide which way they'll exit the bridge.
     */
    CGPoint location = ccp(bridge.bridge.position.x, bridge.bridge.position.y);
    
    int padding = bridge.bridge.contentSize.width / 2;
    
    if (player.position.x < bridge.bridge.position.x - padding) {
        _bridgeEntry = LEFT;
    } else if (player.position.x > bridge.bridge.position.x + padding) {
        _bridgeEntry = RIGHT;
    } else if (player.position.y < bridge.bridge.position.y - padding) {
        _bridgeEntry = DOWN;
    } else if (player.position.y > bridge.bridge.position.y - padding) {
        _bridgeEntry = UP;
    }
    
    _currentBridge = bridge;
    
    
    [mgr removeAllActionsFromTarget:player];
    [mgr resumeTarget:player];
    
    //    printf("Moving to (%f, %f)\n", location.x, location.y);
    //    location.y += 5;
    //    _player.position = location;
    
    [self.undoStack addObject: [[Undoable alloc] initWithPosAndNode:_prevPlayerPos :bridge: _player.color]];
    UIImage *undoD = [UIImage imageNamed:@"left_arrow.png"];
    [_undoBtn setImage:undoD forState:UIControlStateNormal];
    
    [_player moveTo: ccp(location.x, location.y):true];
    
    [bridge enterBridge:_bridgeEntry];
    
    if (bridge.color != NONE) {
        [_player updateColor:bridge.color];
    }
}

- (void)doCross:(CCSprite *) player:(BridgeNode*) bridge:(CCSprite*) object {
    CCActionManager *mgr = [player actionManager];
    [mgr pauseTarget:player];
    
    CGPoint location;
    
    int padding = bridge.bridge.contentSize.width / 2;
    
//    printf("player (%f, %f)\n", player.position.x, player.position.y);
//    printf("bridge (%f, %f)\n", object.position.x, object.position.y);
//    printf("vertical: %i\n", bridge.vertical);
    
    if (bridge.vertical) {
        if (player.position.y + player.contentSize.height < object.position.y + padding) {
            // Then the player is below the bridge
            if (bridge.direction != UP && bridge.direction != NONE) {
                [self bumpObject:player :bridge.bridge];
                return;
            }
            int x = (object.position.x + (object.contentSize.width / 2)) -
                (player.contentSize.width);
            location = ccp(x, object.position.y + object.contentSize.height + 1);
        } else if (player.position.y > (object.position.y + object.contentSize.height) - padding) {
            // Then the player is above the bridge
            if (bridge.direction != DOWN && bridge.direction != NONE) {
                [self bumpObject:player :bridge.bridge];
                return;
            }
            int x = (object.position.x + (object.contentSize.width / 2)) -
                (player.contentSize.width);
            location = ccp(x, (object.position.y - 1) - (player.contentSize.height * 2));
        }
    } else {
        if (player.position.x > (object.position.x + object.contentSize.width) - padding) {
            // Then the player is to the right of the bridge
            if (bridge.direction != LEFT && bridge.direction != NONE) {
                [self bumpObject:player: bridge.bridge];
                return;
            }
            int y = (object.position.y + (object.contentSize.height / 2)) -
                (player.contentSize.height);
            location = ccp((object.position.x - 1) - (player.contentSize.width * 2), y);
        } else if (player.position.x + player.contentSize.width < object.position.x + padding) {
            // Then the player is to the left of the bridge
            if (bridge.direction != RIGHT && bridge.direction != NONE) {
                [self bumpObject:player :bridge.bridge];
                return;
            }
            int y = (object.position.y + (object.contentSize.height / 2)) -
                (player.contentSize.height);
            location = ccp(object.position.x + 1 + object.contentSize.width, y);
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
    
    [self.undoStack addObject: [[Undoable alloc] initWithPosAndNode:_prevPlayerPos :bridge: _player.color]];
    UIImage *undoD = [UIImage imageNamed:@"left_arrow.png"];
    [_undoBtn setImage:undoD forState:UIControlStateNormal];
    
    [_player moveTo: ccp(location.x, location.y):true];
    
    [bridge cross];
    
    if (bridge.color != NONE) {
        [_player updateColor:bridge.color];
    }
    
    [self hasWon];
}

- (void)bumpObject:(CCSprite *) player:(CCSprite*) object {
    /*
     * The player bumped into a river or crossed bridge and is now
     * in the middle of an animation overlapping a river.  We need
     * to stop the animation and move the player back off the river
     * so they aren't overlapping anymore.
     */
    
    CCActionManager *mgr = [player actionManager];
    [mgr pauseTarget:player];
    
    int padding = object.contentSize.width / 2;
    
    /*
     * When the player collides with a river we need to move
     * the player back a little bit so they don't overlap anymore.
     */
    
    if (player.position.y + player.contentSize.height < object.position.y + padding) {
        // Then the player is below the river
        player.position = ccp(player.position.x,
                              player.position.y - padding);
    } else if (player.position.y > (object.position.y + object.contentSize.height) - padding) {
        // Then the player is above the river
        player.position = ccp(player.position.x,
                              player.position.y + padding);
    } else if (player.position.x > (object.position.x) - padding) {
        // Then the player is to the right of the river
        player.position = ccp(player.position.x + padding,
                              player.position.y);
    } else if (player.position.x < object.position.x) {
        // Then the player is to the left of the river
        player.position = ccp(player.position.x - padding,
                              player.position.y);
    } else {
        printf("player (%f, %f)\n", player.position.x, player.position.y);
        printf("river (%f, %f)\n", object.position.x, object.position.y);
        printf("padding (%i)\n", padding);
        printf("This should never happen\n");
    }
    
    [_player playerMoveEnded];
    
    [mgr removeAllActionsFromTarget:player];
    [mgr resumeTarget:player];
    
    [self hasWon];
    
}

-(void) hasWon {
    if ([self.currentLevel hasWon]) {
        printf("You've won");
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setBool:TRUE forKey:[NSString stringWithFormat:@"%@-won", self.currentLevel.levelId]];
        [defaults synchronize];
    }
    
}

- (void)spawnPlayer:(int) x: (int) y {
    
    _player = [[PlayerNode alloc] initWithTag:PLAYER:BLACK:_layerMgr];
    _player.player.position = ccp(x, y);
    
    //   CCSprite *player = [_player player];
    /*
     [_player runAction:
     [CCSequence actions:
     [CCMoveTo actionWithDuration:1.0 position:ccp(300,100)],
     [CCMoveTo actionWithDuration:1.0 position:ccp(200,200)],
     [CCMoveTo actionWithDuration:1.0 position:ccp(100,100)],
     nil]];
     */
    //    [self addChildToSheet:player];
    
}

-(bool)inObject:(CGPoint) p {
    for (BridgeNode *n in self.currentLevel.bridges) {
        if (CGRectContainsPoint([n.bridge boundingBox], p)) {
            return true;
        }
    }
    
    for (CCSprite *s in self.currentLevel.rivers) {
        if (CGRectContainsPoint([s boundingBox], p)) {
            return true;
        }
    }
    
    for (HouseNode *h in self.currentLevel.houses) {
        if (CGRectContainsPoint([h.house boundingBox], p)) {
            return true;
        }
    }
    
    return false;
    
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (_inBridge) {
        [self finishCross4:location];
        return;
    }
    
    if (_player == nil) {
        if (![self inObject:location]) {
            [self spawnPlayer:location.x: location.y];
        }
    } else {
        _inCross = false;
        _prevPlayerPos = _player.player.position;
        
        [_player moveTo:location];
//        [_player.player runAction:
//         [CCMoveTo actionWithDuration:distance/velocity position:ccp(location.x,location.y)]];
    }
    
}

-(CGSize)winSizeTiles {
    CGSize winSize = [self getWinSize];
    return CGSizeMake(winSize.width / _layerMgr.tileSize.width,
                      winSize.height / _layerMgr.tileSize.height);
}

-(CGPoint)tileToPoint:(int) x: (int)y {
    printf("tileToPoint (%i, %i)\n", x, y);
    printf("tileSize (%f, %f)\n", _layerMgr.tileSize.width, _layerMgr.tileSize.height);
    return CGPointMake(x * _layerMgr.tileSize.width,
                       y * _layerMgr.tileSize.height);
}

-(CGSize)getWinSize {
    //CGRect r = [[UIScreen mainScreen] bounds];
    //return r.size;
    return [[CCDirector sharedDirector] winSize];
}

-(void)dealloc {
    
    delete _world;
    delete _debugDraw;
    
    delete _contactListener;
    [_spriteSheet release];
    [_player dealloc];
    
    [_undoStack release];
    _undoStack = nil;

    
//    [self.currentLevel dealloc];
    
    [super dealloc];
}

@end