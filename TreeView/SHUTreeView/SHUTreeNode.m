

#import "SHUTreeNode.h"

@interface SHUTreeNode ()

/// redefining exposed parentPath property as retain
@property (nonatomic, strong) NSString *parentPath;

/// internal property, lazy loaded
@property (nonatomic, strong, readonly) NSDictionary *properties;

///  internal property, always reads properties from disk
@property (nonatomic, assign, readonly) NSDictionary *nonCashedProperties;

@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) SHUTreeNode *parent;
@property (nonatomic, readwrite) NSInteger depth;
@end


@implementation SHUTreeNode
{
	NSDictionary *_properties;
}


@synthesize filename = _name;
@synthesize directoryIsExpanded = _expanded;


//#define GIASSERT(error, method) 
#define GIASSERT(error, method) if ((error)) NSLog(@"ERROR: %s: %@", (method), [(error) localizedDescription]);


#pragma mark - Life Cicle

- (id) initWithName:(NSString *)name parent:(SHUTreeNode *)aParent{
	if ((self = [super init])){
		_name = name;
		_parent = aParent;
		_parentPath = nil;
		_properties = nil;
		_children = nil;
		_depth = -1;
		_expanded = NO;
	}
	return self;
}

- (id) initWithName:(NSString *)name parentPath:(NSString *)aParentPath{
	if ((self = [super init])){
		_name = name;
		_parent = nil;
		_parentPath = aParentPath;
		_properties = nil;
		_children = nil;
		_depth = 0;
		_expanded = NO;
	}
	return self;
}


#pragma mark - private methods

- (NSDictionary *) nonCashedProperties{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	NSString *path = self.absolutePath;
	NSDictionary *props = [fm attributesOfItemAtPath:path error:&error];
	//GIASSERT(error, _cmd);
	return props;
}

- (NSDictionary *)properties{
	if (!_properties) {
		_properties = [self nonCashedProperties];
	}
	return _properties;
}

/// loads children (retains it, so children must be released later)
- (void) _loadChildren{ 
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	NSArray *paths = [fm contentsOfDirectoryAtPath:self.absolutePath error:&error];
	//GIASSERT(error, _cmd);
	_children = [[NSMutableArray alloc] init];
	for (NSString *path in paths) {
		SHUTreeNode *childNode = [[SHUTreeNode alloc] initWithName:path parent:self];
		[_children addObject:childNode];
	}
	
}


#pragma mark - public methods


- (void) expand{
	if (self.isDirectory && !self.directoryIsExpanded){
		if (!_children)	[self _loadChildren];
		_expanded = YES;
	}
}
- (void) collapse{
	_expanded = NO; //objects will be released when memory is needed
}

- (void) flushCache{
	if (!self.directoryIsExpanded) {
		_children = nil;
	}
	_properties = nil;
}


#pragma mark - helper

NSString *space(int x){
	NSMutableString *res = [NSMutableString string];
	for (int i =0; i<x; i++) {
		[res appendString:@" "];
	}
	return res;
}

- (NSString *) description{
	
	return [NSString stringWithFormat:@"%@%@ %@", space(self.depth),self.isDirectory?@"D":@"F", self.filename];
}


#pragma mark - getter

- (NSMutableArray *) children{
	if (self.isDirectory && !_children) {
		[self _loadChildren]; //_children is alloc/init must be released later
	}
	return _children;
}


- (NSDate *) creationDate{
	return [self.properties fileCreationDate]; //cashed properties
}
- (NSDate *) modificationDate{
	return [self.properties fileModificationDate];
}
- (void) setModificationDate:(NSDate *)date{
	//to do this _properties has to be mutable or create a new object _properties
}

- (NSInteger) depth{
	if (_depth == -1) {
		_depth = self.parent.depth + 1;
	}
	return _depth;
}

- (NSString *)absolutePath{
	return (self.parent)?
	[self.parent.absolutePath stringByAppendingPathComponent:self.filename]:
	[self.parentPath stringByAppendingPathComponent:self.filename];
}

- (NSString *)fileExtension{
	return [[self.filename lastPathComponent] pathExtension];
}

- (BOOL) isDirectory{
	return [NSFileTypeDirectory isEqualToString:[self.properties fileType]];
}

//- (BOOL) directoryIsExpanded{
//	return (self.isDirectory && _children);
//}

@end
