//
//  CoreTextLinkData.m
//  CoreText进阶封装
//
//  Created by baiqiang on 16/1/6.
//  Copyright © 2016年 baiqiang. All rights reserved.
//

#import "CoreTextLinkData.h"

@implementation CoreTextLinkData
+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data {
    NSLog(@"point.x = %f point.y = %f",point.x,point.y);
    
    //得到文本的CTFrameRef
    CTFrameRef ctFrame = data.ctFrame;
    //得到ctFrame所有行信息
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    if (lines == nil) {
        return nil;
    }
    
    CFIndex linesCount = CFArrayGetCount(lines);
    NSLog(@"linesCount = %li",linesCount);
    
    CoreTextLinkData *linkdata = nil;
    
    //这是一个CGPoint的数组 存储每一行的CGPoint
    CGPoint linesOrigins[linesCount];
    
//    range： 用来指定我们想获取的line的origion(原点)的个数如果是0的话那么就会返回frame下全部的line
//    linesOrigins:存放所有原点的数组
//    ctFrame:文本的CTFrameRef
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), linesOrigins);
    
    //由于CoreText和UIKit坐标系不同所以要做个对应转换 坐标转换
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1, -1);
    
    //遍历所有line
    for (int i = 0; i < linesCount; i++) {
        //得到每一行line的坐标
        CGPoint linePoint = linesOrigins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        //获取当前行的rect信息
        //通过该方法 获取当前行Rect信息 参数：当前行是啥 坐标：当前行的坐标
        //getLineBounds这个函数：配置行的位置信息 之后获取行的宽度信息 同时得到其他信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        NSLog(@"flippedRect.size.width = %f flippedRect.origin.y = %f",flippedRect.size.width,flippedRect.origin.y);
        //将CoreText坐标转换为UIKit坐标
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        //判断点是否在Rect当中 rect 是字符所在范围
        if (CGRectContainsPoint(rect, point)) {
            //获取点在line行中的位置 然后判断属于这一行中的哪个CTRun???
            CGPoint relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect));
#pragma mark - Request  判断属于该行的哪个CTRun
            //获取点中字符在line中的位置(在属性文字中是第几个字)
            CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
            NSLog(@"idx 第几个字呢？ = %li",idx);
            
#pragma mark - attention 判断是否在那个蓝色链接的范围中
            //判断此字符是否在链接属性文字当中
            //前面几行有： CoreTextLinkData *linkdata = nil;
            //linkAtIndex:这个函数就是通过idx根据位置来判断第idx个字符是否在data.linkArray 这个之前就设置好的存放链接的数组中
            //意思就是看你点击的这个字符是否是之前设置好的字符链接中的字符中的一个
            linkdata = [self linkAtIndex:idx linkArray:data.linkArray];
            break;
        }
    }
    return linkdata;
}

+ (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    //配置line行的位置信息
    CGFloat ascent = 0;
    CGFloat descent = 0;
    CGFloat leading = 0;
    //在获取line行的宽度信息的同时得到其他信息
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    NSLog(@"width = %f",width);
    CGFloat height = ascent + descent;
    NSLog(@"height = %f",height);
    return CGRectMake(point.x, point.y, width, height);
}

+ (CoreTextLinkData *)linkAtIndex:(CFIndex)i linkArray:(NSArray *)linkArray {
    CoreTextLinkData *linkdata = nil;
    for (CoreTextLinkData *data in linkArray) {
        //data.range: 文字在属性文字中的范围
        //NSLocationInRange: 判断所给的下标i是否在data.range内 data.range是NSRange类型
        if (NSLocationInRange(i, data.range)) {
            linkdata = data;
            break;
        }
    }
    return linkdata;
}

//该根据ViewCOntroller.m 文件与 BQDisplayView.m文件看下一个文件该看什么了 CoreTextLinkData的下一个文件

@end
