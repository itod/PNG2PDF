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
//    CGPDFDocumentRef outPdf = CGPDFDocumentCreateWithURL((CFURLRef)outPdfURL);
//    assert(outPdf);

    CGRect mediaBox = CGRectMake(0.0, 0.0, 612.0, 792.0);
    
    CGContextRef outPdfFileCtx = CGPDFContextCreateWithURL((CFURLRef)outPdfURL, &mediaBox, NULL);
    
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *pngFilePaths = [mgr subpathsOfDirectoryAtPath:pngDirPath error:nil];
    for (NSString *pngFilename in pngFilePaths) {
        if (![[pngFilename pathExtension] isEqualToString:@"png"]) continue;
        
        NSString *pngFilePath = [pngDirPath stringByAppendingPathComponent:pngFilename];

        CGContextSaveGState(outPdfFileCtx); {
            CGContextBeginPage(outPdfFileCtx, &mediaBox);
            
            NSImage *img = [[[NSImage alloc] initWithContentsOfFile:pngFilePath] autorelease];
            assert(img);
            CGRect imgRect = CGRectMake(0.0, 0.0, img.size.width, img.size.height);
            CGImageRef cgimg = [img CGImageForProposedRect:&imgRect context:[NSGraphicsContext currentContext] hints:@{NSImageHintInterpolation:@(NSImageInterpolationHigh)}];
            
            CGContextDrawImage(outPdfFileCtx, mediaBox, cgimg);
            
            CGContextEndPage(outPdfFileCtx);
        } CGContextRestoreGState(outPdfFileCtx);
    }
    
//    NSUInteger c = CGPDFDocumentGetNumberOfPages(outPdf);
//    for (NSInteger i = 1; i <= c; ++i) {
//        CGPDFPageRef page = CGPDFDocumentGetPage(outPdf, i);
//        CGRect inMediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
//
//        NSArray *frameVals = [pageFrames objectAtIndex:i-1];
//
//        for (id frameVal in frameVals) {
//            CGRect inFrame = [frameVal rectValue];
//
//            CGRect outFrame = inFrame;
//            outFrame.origin.y = NSHeight(inMediaBox)-NSMinY(inFrame)-NSHeight(inFrame);
//
//            CGContextSaveGState(outPdfFileCtx); {
//                CGRect r = inFrame;
//                r.origin = CGPointZero;
//                r = CGRectApplyAffineTransform(r, CGAffineTransformMakeScale(scale, scale));
//                CGContextBeginPage(outPdfFileCtx, &r);
//
//                {
//                    CGContextScaleCTM(outPdfFileCtx, scale, scale);
//                    CGContextTranslateCTM(outPdfFileCtx, (-outFrame.origin.x)+0.0, (-outFrame.origin.y)+0.0);
//                }
//
//                // EMBIGGEN. MAYBE REMOVE THIS?
//                //                {
//                //                    CGContextTranslateCTM(outPdfFileCtx, -40.0, -40.0);
//                //                    CGContextScaleCTM(outPdfFileCtx, 1.14, 1.14);
//                //                }
//
//                CGContextClipToRect(outPdfFileCtx, outFrame);
//                CGContextDrawPDFPage(outPdfFileCtx, page);
//                CGContextEndPage(outPdfFileCtx);
//            } CGContextRestoreGState(outPdfFileCtx);
//
//        }
//    }
    
    CGPDFContextClose(outPdfFileCtx);
    CGContextRelease(outPdfFileCtx);
//    CGPDFDocumentRelease(outPdf);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        run();
        NSLog(@"Done");
    }
    return 0;
}
