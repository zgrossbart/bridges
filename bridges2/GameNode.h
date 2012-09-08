@protocol GameNode <NSObject>
@required
- (void) addSprite;
- (NSArray*) controls;
- (void) undo;

@property (nonatomic, assign, readonly) int tag;
@property (nonatomic, assign, readonly) int coins;

@end