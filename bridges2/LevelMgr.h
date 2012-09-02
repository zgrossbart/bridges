//
//  LevelMgr.h
//  bridges2
//
//  Created by Zack Grossbart on 9/1/12.
//
//

#import <Foundation/Foundation.h>

@interface LevelMgr : NSObject

+(LevelMgr *)getLevelMgr;

@property (readonly) NSMutableDictionary *levels;
@property (readonly,copy) NSArray *levelIds;


@end