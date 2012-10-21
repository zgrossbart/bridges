//
//  LevelSet.h
//  bridges2
//
//  Created by Zack Grossbart on 10/21/12.
//
//

#import <Foundation/Foundation.h>

@interface LevelSet : NSObject

-(id)initWithNameAndLevels: (NSString*) name: (NSArray*) levelIds: (NSDictionary*) levels: (int) index;

@property (readonly, retain) NSString *name;
@property (readonly) int index;
@property (readonly, retain) NSArray *levelIds;
@property (readonly, retain) NSDictionary *levels;

@end
