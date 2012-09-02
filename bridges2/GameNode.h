@protocol GameNode <NSObject>
@required
- (void) addSprite;
- (void) undo;

@property (nonatomic, assign, readonly) int tag;

@end