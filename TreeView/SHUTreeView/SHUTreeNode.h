
#import <Foundation/Foundation.h>


@interface SHUTreeNode : NSObject


- (id) initWithName:(NSString *)name parent:(SHUTreeNode *)parent;
- (id) initWithName:(NSString *)name parentPath:(NSString *)parentPath;


/// accessor for _name
@property (nonatomic, strong, readonly) NSString *filename;

/// lazy property. If directory then it is not nil
@property (nonatomic, strong, readonly) NSMutableArray *children;

/// accessor for _parent
@property (nonatomic, strong, readonly) SHUTreeNode *parent;

/// calculates the extension from _name
@property (nonatomic, weak, readonly) NSString *fileExtension;

/// calculates absolute by recursively accesing its parent or parentPath
@property (nonatomic, weak, readonly) NSString *absolutePath;

/// tells if node represents a directory
@property (nonatomic, readonly) BOOL isDirectory;

/// lazy property, accesor of creation date. cashed the date
@property (nonatomic, weak, readonly) NSDate *creationDate;

/// accesor of modification date, always read date from disk
@property (nonatomic, weak, readwrite) NSDate *modificationDate;

/// lazy property. depth of node
@property (nonatomic, readonly) NSInteger depth;

@property (nonatomic, readonly) BOOL directoryIsExpanded;


/*
	Since each node represents a file on disk.
	There are 3 kind of operations:
	1: Phisical: When operation moves/creates/deletes file on disk 
	2: Logical: When operation moves/creates/deletes file on memory (only inside the tree)
	3: Both: When operation include both 1 and 2
 */



/// changes flag, loads children if needed.
- (void) expand;

/// changes flag, does not unload children
- (void) collapse;


/// children are unloaded here if needed
- (void) flushCache;

@end
