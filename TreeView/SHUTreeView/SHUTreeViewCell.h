
#import <Foundation/Foundation.h>

//ivars in categories needs: 
// LLVM 1.6 compiler
// -Xclang -fobjc-nonfragile-abi2 in $OTHER_CFLAGS in project settings

@interface SHUTreeViewCell : UITableViewCell 


//changes the state of the cell (with animation)
@property (nonatomic, getter=isExpanded) BOOL expanded;
//@property (nonatomic) BOOL inPseudoEditMode;

/// designated initializer
- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier;

/// title to appear in the cell: use this instead of cell.textLabel.text
- (void) setTitle:(NSString *)title;

/// image to appear and if it is directory a triangular indicator will appear
- (void) setIcon:(UIImage *)icon isDirectory:(BOOL)isDir;

- (void) setPseudoEditingMode:(BOOL)pseudoEditing animated:(BOOL)animated;

@end
