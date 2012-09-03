//
//  LevelMgr.h
//  bridges2
//
//  Created by Zack Grossbart on 9/1/12.
//
//

#import <Foundation/Foundation.h>
#import "Level.h"

@interface LevelMgr : NSObject {
    CCDirectorIOS	*director_;							// weak ref
    CCGLView *glView_;
    
    bool _hasInit;
}

+(LevelMgr *)getLevelMgr;
-(void)drawLevels:(CGRect) bounds;

@property (readonly) NSMutableDictionary *levels;
@property (readonly,copy) NSArray *levelIds;
@property (readonly) CCGLView *glView;


@end