//
//  LevelSet.h
//  bridges2
//
//  Created by Zack Grossbart on 10/21/12.
//
//

#import <Foundation/Foundation.h>

@interface LevelSet : NSObject

-(id)initWithNameAndLevels: (NSString*) name levelIds:(NSArray*) levelIds levels:(NSDictionary*) levels index:(int) index imageName:(NSString*) imageName;

@property (readonly, retain) NSString *name;
@property (readonly, retain) NSString *imageName;
@property (readonly) int index;
@property (readonly, retain) NSArray *levelIds;
@property (readonly, retain) NSDictionary *levels;

@end
