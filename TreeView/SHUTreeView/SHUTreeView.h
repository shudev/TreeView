
#import <Foundation/Foundation.h>

@class SHUTreeNode;

@interface SHUTreeView : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BOOL isInPseudoEditMode;
@property (nonatomic, strong) NSMutableArray *selectedNodes;
@property (nonatomic, strong) NSMutableArray *sortDescriptors;
@property (nonatomic, strong, readonly) NSArray *nodes;

- (id) initWithPath:(NSString *)baseDirectoryPath;

@end
