//#import "Box2D.h"
#import "cocos2d.h"
#import "GLES-Render.h"

#define PTM_RATIO 32.0

@interface HelloWorldLayer : CCLayerColor {
    
@private
    b2World *_world;
}

+ (id) scene;


@end