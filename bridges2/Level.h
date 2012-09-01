//
//  Level.h
//  bridges2
//
//  Created by Zack Grossbart on 9/1/12.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LayerMgr.h"

@interface Level : NSObject {
    
}

-(id) initWithJson:(NSString*) jsonString: (LayerMgr*) layerMgr;

@property (readonly) NSMutableArray *rivers;
@property (readonly) NSMutableArray *bridges;
@property (readonly) NSMutableArray *houses;

@property (readonly) LayerMgr *layerMgr;

@end


