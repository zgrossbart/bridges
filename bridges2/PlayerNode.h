#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"

@interface PlayerNode : CCLayer {
@private
    int _tag;
    LayerMgr *_manager;
    
}

-(id)initWithTag:(int) tag:(int) color:(LayerMgr*) layerMgr;
-(void)updateColor:(int)color;
-(int)tag;

@property (readonly) CCSprite *player;
@property (nonatomic, assign, readonly) int color;

@end