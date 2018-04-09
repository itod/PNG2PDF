//
//  main.m
//  PNG2PDF
//
//  Created by Todd Ditchendorf on 4/8/18.
//  Copyright © 2018 Celestial Teapot. All rights reserved.
//

#import <AppKit/AppKit.h>

void run() {
    NSString *pngDirPath = [@"~/Desktop/Book/" stringByExpandingTildeInPath];
    
    NSString *outPdfPath = @"~/Desktop/Book.pdf";
    NSURL *outPdfURL = [NSURL fileURLWithPath:[outPdfPath stringByExpandingTildeInPath]];
    assert(outPdfURL);

    CGRect mediaBox = CGRectMake(0.0, 0.0, 612.0, 792.0);
    
    CGContextRef outPdfFileCtx = CGPDFContextCreateWithURL((CFURLRef)outPdfURL, &mediaBox, NULL);
    
    NSUInteger c = 0;
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *pngFilePaths = [mgr contentsOfDirectoryAtPath:pngDirPath error:nil];
    pngFilePaths = [pngFilePaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (![[obj1 pathExtension] isEqualToString:@"png"]) return NSOrderedAscending;
        if (![[obj2 pathExtension] isEqualToString:@"png"]) return NSOrderedAscending;
        return [[obj1 stringByDeletingPathExtension] integerValue] - [[obj2 stringByDeletingPathExtension] integerValue];
    }];
    
    for (NSString *pngFilename in pngFilePaths) {
        if (![[pngFilename pathExtension] isEqualToString:@"png"]) continue;
        
        NSString *pngFilePath = [pngDirPath stringByAppendingPathComponent:pngFilename];

        CGContextSaveGState(outPdfFileCtx); {
            CGContextBeginPage(outPdfFileCtx, &mediaBox);
            
            NSImage *img = [[[NSImage alloc] initWithContentsOfFile:pngFilePath] autorelease];
            assert(img);
            CGRect imgRect = CGRectMake(0.0, 0.0, img.size.width, img.size.height);
            CGImageRef cgimg = [img CGImageForProposedRect:&imgRect context:[NSGraphicsContext currentContext] hints:@{NSImageHintInterpolation:@(NSImageInterpolationLow)}];
            
            CGContextDrawImage(outPdfFileCtx, mediaBox, cgimg);
            
            CGContextEndPage(outPdfFileCtx);
            NSLog(@"%@", @(++c));
        } CGContextRestoreGState(outPdfFileCtx);
    }

    CGPDFContextClose(outPdfFileCtx);
    CGContextRelease(outPdfFileCtx);
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        run();
        NSLog(@"Done");
    }
    return 0;
}
