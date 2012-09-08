//#import "Box2D.h"
#import "cocos2d.h"
#import "GLES-Render.h"
#import "LayerMgr.h"
#import "MyContactListener.h"
#import "PlayerNode.h"
#import "Level.h"
#import "Bridge4Node.h"

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
@property (readonly) NSMutableArray *undoStack;


@end