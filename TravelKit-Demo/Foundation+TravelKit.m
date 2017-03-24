//
//  Foundation+TravelKit.m
//  TravelKit Demo
//
//  Created by Michal Zelinka on 20/03/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <objc/runtime.h>
#import "Foundation+TravelKit.h"


@implementation NSObject (TravelKit)

- (void)swizzleSelector:(SEL)swizzled withSelector:(SEL)original
{
	Class class = [self class];

	Method origMethod = class_getInstanceMethod(class, original);
	Method overrideMethod = class_getInstanceMethod(class, swizzled);

	if (class_addMethod(class, original,
		method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod)))
	{
		class_replaceMethod(class, swizzled,
			method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	}
}

- (void)swizzleSelector:(SEL)swizzledSelector ofClass:(Class)swizzledClass
           withSelector:(SEL)originalSelector ofClass:(Class)originalClass
{
	Method oldMethod = class_getInstanceMethod(originalClass, originalSelector);
	Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);

	class_addMethod(originalClass, swizzledSelector,
					method_getImplementation(swizzledMethod),
					method_getTypeEncoding(swizzledMethod));

	swizzledMethod = class_getInstanceMethod(originalClass, swizzledSelector);
	method_exchangeImplementations(oldMethod, swizzledMethod);
}

@end


@implementation NSArray (TravelKit)

- (id)safeObjectAtIndex:(NSUInteger)index
{
	if (self.count > index)
		return self[index];
	return nil;
}

@end
