//
//  WebHelper-FileService.m
//  BAT
//
//  Created by Gaston Funes on 7/7/12.
//  Copyright 2012 Gaston Funes. All rights reserved.
//

#import "WebHelper-FileService.h"
#import "MIMEHelper.h"

@implementation WebHelperFileService

@synthesize cwd;

- (NSString *)css {
	return @"<style>/* based on iui.css (c) 2007 by iUI Project Members */ body { margin: 0;font-family: Helvetica;background:#FFFFFF;color:#000000;overflow-x:hidden;-webkit-user-select:none;-webkit-text-size-adjust:none; } body > *:not(.toolbar) { display: none;position:absolute;margin:0;padding:0;left:0;top:45px;width:100%;min-height:372px; } body > *[selected=\"true\"] { display: block; } a[selected],a:active { background-color:#194fdb !important;background-repeat:no-repeat,repeat-x;background-position:right center,left top;color:#FFFFFF !important; } body > .toolbar {box-sizing:border-box;-moz-box-sizing: border-box;-webkit-box-sizing: border-box; border-bottom:1px solid #2d3642;border-top:1px solid #6d84a2;padding:10px;height:45px;background:#6d84a2 repeat-x; } .toolbar > h1 {position:absolute;overflow:hidden;font-size:20px;text-align:center;font-weight:bold;text-shadow:rgba(0, 0, 0, 0.4) 0px -1px 0;text-overflow:ellipsis;white-space:nowrap;color:#FFFFFF;margin:1px 0 0 -120px;left:50%;width:240px;height:45px; } body > ul > li {position:relative;margin:0;border-bottom:1px solid #E0E0E0;padding:8px 0 8px 10px;font-size:20px;font-weight:bold;list-style:none; } body > ul > li > a {margin:-8px 0 -8px -10px;padding:8px 32px 8px 10px;text-decoration:none;color:inherit; } a[target=\"_replace\"] {box-sizing:border-box;-webkit-box-sizing:border-box;padding-top:25px;padding-bottom:25px;font-size: 18px;color:cornflowerblue;background-color:#FFFFFF;background-image:none; } body > .dialog {top:0;width:100%;min-height:417px;z-index:2;background:rgba(0, 0, 0, 0.8);padding:0;text-align:right; } .dialog > fieldset {box-sizing:border-box;-webkit-box-sizing:border-box;width:100%;margin:0;border:none;border-top:1px solid #6d84a2;padding:10px 6px;background:#7388a5 repeat-x; } .dialog > fieldset > h1 {margin:0 10px 0 10px;padding:0;font-size:20px;font-weight:bold;color:#FFFFFF;text-shadow:rgba(0, 0, 0, 0.4) 0px -1px 0;text-align:center; } .dialog > fieldset > label {position:absolute;margin:16px 0 0 6px;font-size:14px;color:#999999; } p {font-family:Helvetica;background:#FFFFFF;color:#000000;padding:15px;font-size:20px;margin-left:15%;margin-right:15%;text-align:center; }</style>\n";
}

- (NSString *)createindex {    
	NSMutableString *outdata = [NSMutableString string];
	
	[outdata appendString:@"<html>"];
	[outdata appendFormat:@"<head><title>Transmission Files</title>\n"];
	[outdata appendString:@"<meta name=\"viewport\" content=\"width=320;initial-scale=1.0;maximum-scale=1.0;user-scalable=0;\"/>"];
    [outdata appendString:[NSString stringWithFormat:@"<link href=\"%@\" rel=\"icon\" />\n", [[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"] stringByAppendingPathComponent:@"images"] stringByAppendingString:@"/favicon.ico"]]];
    [outdata appendString:[NSString stringWithFormat:@"<link href=\"%@\" rel=\"shortcut icon\" />\n", [[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"] stringByAppendingPathComponent:@"images"] stringByAppendingString:@"/favicon.ico"]]];
    [outdata appendString:[NSString stringWithFormat:@"<link href=\"%@\" rel=\"apple-touch-icon\" />\n", [[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"] stringByAppendingPathComponent:@"images"] stringByAppendingString:@"/webclip-icon.png"]]];
	[outdata appendString:[self css]];
	[outdata appendString:@"<script type=\"application/x-javascript\">"];
	[outdata appendString:@"window.onload = function() { setTimeout(function() { window.scrollTo(0,1);), 100); } }"];
	[outdata appendString:@"</script>"];
	[outdata appendString:@"</head><body>"];
	[outdata appendString:@"<div class=\"toolbar\">	<h1 id=\"pageTitle\">Downloads</h1> <a id=\"backButton\" class=\"button\" href=\"#\"></a></div>"];
	[outdata appendString:@"<ul id=\"home\" title=\"Files\" selected=\"true\">"];

    if (![self.cwd isEqualToString:@"/"] && [[self.cwd substringFromIndex:([self.cwd length] - 1)] isEqualToString:@"/"]) {
		NSString *nwd = [[[self.cwd stringByDeletingLastPathComponent] stringByAbbreviatingWithTildeInPath] stringByReplacingOccurrencesOfString:[self searchDirectoryPath] withString:@""];
		if (![nwd isEqualToString:@"/"]) {
			[outdata appendFormat:@"<li><a href=\"%@/\">... Parent Directory</a></li>\n", nwd];
        }
	}
	
	// Read in the files
    NSString *wd = [([self.cwd length] && ![self.cwd isEqualToString:@"/"] ? self.cwd : [self searchDirectoryPath]) stringByExpandingTildeInPath];

    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL URLWithString:[wd stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error) {
        if (error) {
            return NO;
        } else {
            return YES;
        }
    }];

    for (NSURL *fileURL in enumerator) {
        NSString *fileName;
        [fileURL getResourceValue:&fileName forKey:NSURLNameKey error:nil];

        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];

        NSString *pathSeparator = @"";
        if ([isDirectory boolValue]) {
            [enumerator skipDescendants];

            pathSeparator = @"/";
        }

        NSString *cpath = [[wd stringByAppendingPathComponent:fileName] stringByAbbreviatingWithTildeInPath];

        NSString *mime = [MIMEHelper mimeForExt:[cpath pathExtension]];
        NSString *mimeType = [[mime componentsSeparatedByString:@"/"] firstObject];
        NSString *detailData = @"";
        if ([mimeType isEqualToString:@"image"]) {
            detailData = [NSString stringWithFormat:@"<img src=\"%@\" width=\"200\" height\"200\"> ", cpath];
        } else if ([mimeType isEqualToString:@"video"]) {
            detailData = [NSString stringWithFormat:@"<video width=\"200\" height\"200\" controls><source src=\"%@\" type=\"%@\"></video> ", cpath, mime];
        } else if ([mimeType isEqualToString:@"audio"]) {
            detailData = [NSString stringWithFormat:@"<audio width=\"200\" height\"200\" controls><source src=\"%@\" type=\"%@\"></audio>", cpath, mime];
        }

        [outdata appendFormat:@"<li>%@<a href=\"%@%@\">%@%@</a></li>\n", detailData, [[cpath stringByReplacingOccurrencesOfString:[self searchDirectoryPath] withString:@""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] , pathSeparator, fileName, pathSeparator];
    }
    
    //[outdata appendString:@"<li><a href=\"delete/\" onclick=\"javascript:return confirm('¿Are you sure?');\">Delete Files</a></li>\n"];
	[outdata appendString:@"</ul>"];
	[outdata appendString:@"</body></html>"];
    
	return outdata; 
}

- (void)produceError:(NSString *)errorString forFD:(int)fd {
	NSMutableString *outdata = [NSMutableString string];
    
	[outdata appendString:@"<html>"];
	[outdata appendString:@"<head><title>Error</title>\n"];
	[outdata appendString:@"<meta name=\"viewport\" content=\"width=320;initial-scale=1.0;maximum-scale=1.0;user-scalable=0;\"/>"];
	[outdata appendString:[self css]];
	[outdata appendString:@"</head><body>"];
	[outdata appendString:@"<div class=\"toolbar\">	<h1 id=\"pageTitle\">Error</h1>	<a id=\"backButton\" class=\"button\" href=\"#\"></a></div>"];
	[outdata appendFormat:@"<p id=\"ErrorPara\" selected=\"true\"><br />%@<br /><br />Go <a href=\"#\" onClick=\"history.go(-1);return true;\">back</a> or return to the <a href=\"/\">main browser</a></p>", errorString];
	[outdata appendString:@"</body></html>"];
    
	write(fd, [outdata UTF8String], [outdata length]);
	close(fd);
}

- (void)handleWebRequest:(int)fd {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
	static char buffer[BUFSIZE + 1];
	long len = read(fd, buffer, BUFSIZE);
	
    buffer[len] = '\0';
	
	NSString *request = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
	NSArray *reqs = [request componentsSeparatedByString:@"\n"];
    
    if (reqs && reqs.count) {
        NSString *getreq = [reqs objectAtIndex:0];
        
        if (getreq && getreq.length > 4) {
            getreq = [getreq substringFromIndex:4];
            
            NSRange range = [getreq rangeOfString:@"HTTP/"];
            if (range.location == NSNotFound) {
                //printf("Error: GET request was improperly formed\n");
                close(fd);
                
                goto exit;
            }
            
            NSString *filereq = [[getreq substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([filereq isEqualToString:@"/"]) {
                self.cwd = filereq;
                NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type:text/html;charset=utf-8\r\n\r\n"];
                write(fd, [outcontent UTF8String], [outcontent length]);
                
                NSString *outdata = [self createindex];
                write(fd, [outdata UTF8String], [outdata length]);
                close(fd);
                
                goto exit;
            }

            NSString *addStr = @"";
            if ([[filereq substringFromIndex:([filereq length] - 1)] isEqualToString:@"/"])
                addStr = @"/";

            if ([[filereq substringToIndex:1] isEqualToString:@"/"])
                filereq = [NSString stringWithFormat:@"%@%@", [self searchDirectoryPath], filereq];

            filereq = [[[filereq stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByExpandingTildeInPath] stringByAppendingString:addStr];
            /*if ([filereq isEqualToString:@"/delete/"]) {
                NSError *error = nil; 
                for (NSString *pathFile in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self searchDirectoryPath] error:&error]) {
                    if (![pathFile hasPrefix:@"."]) {
                        [[NSFileManager defaultManager] removeItemAtPath:[[self searchDirectoryPath] stringByAppendingPathComponent:pathFile] error:&error];
                    }
                }
                
                NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type:text/html;charset=utf-8\r\n\r\n"];
                write(fd, [outcontent UTF8String], [outcontent length]);
                
                NSString *outdata = [self createindex];
                write(fd, [outdata UTF8String], [outdata length]);
                close(fd);
                
                goto exit;
            }*/
            
            // Primary index.html
            if ([filereq hasSuffix:@"/"])  {
                self.cwd = filereq;
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:filereq]) {
                    //printf("Error: folder not found.\n");
                    [self produceError:@"Requested folder was not found." forFD:fd];
                    
                    goto exit;
                }
                
                NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type:text/html;charset=utf-8\r\n\r\n"];
                write(fd, [outcontent UTF8String], [outcontent length]);
                
                NSString *outdata = [self createindex];
                write(fd, [outdata UTF8String], [outdata length]);
                close(fd);
                
                goto exit;
            }
            
            NSString *mime = [MIMEHelper mimeForExt:[filereq pathExtension]];
            if (!mime) {
                //printf("Error recovering mime type.\n");
                [self produceError:@"Sorry, this file type is not supported." forFD:fd];
                
                goto exit;
            }
            
            // Output the file
            NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type:%@\r\n\r\n", mime];
            write (fd, [outcontent UTF8String], [outcontent length]);
            
            NSData *data = [NSData dataWithContentsOfFile:filereq];
            if (!data) {
                //printf("Error: file not found.\n");
                [self produceError:@"File was not found. Please check the requested path and try again." forFD:fd];
                
                goto exit;
            }
            
            //printf("Writing %lu bytes from file\n", (unsigned long)[data length]);
            write(fd, [data bytes], [data length]);
            close(fd);
        }
    }
	
exit:
	[pool release];
}

- (NSString *)searchDirectoryPath {
    return [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Downloads"] stringByAbbreviatingWithTildeInPath];
}

- (void)dealloc {
    self.cwd = nil;
    
    [super dealloc];
}

@end
