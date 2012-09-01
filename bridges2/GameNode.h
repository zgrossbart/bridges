@protocol GameNode <NSObject>
@required
- (void) addSprite;

@property (nonatomic, assign, readonly) int tag;

@end