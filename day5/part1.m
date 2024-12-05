//
//  main.m
//  AoC2024Day5
//
//  Created by Lucas F on 05/12/2024.
//
//  I would like to never do anything in this language ever again.
//  RISC-V Assembly and COBOL were both more enjoyable than this.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *inputFilePath = [NSString stringWithFormat:@"%@/Documents/aoc2024/AoC2024Day5/AoC2024Day5/input.txt", NSHomeDirectory()];
        NSString *inputFileContents = [NSString stringWithContentsOfFile:inputFilePath encoding:NSUTF8StringEncoding error:nil];
        
        NSInteger count = 0;
        NSInteger middleTotal = 0;
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        
        NSArray *inputParts = [inputFileContents componentsSeparatedByString:@"\n\n"];
        NSArray *rawOrderingRules = [inputParts[0] componentsSeparatedByString:@"\n"];
        NSArray *rawUpdates = [inputParts[1] componentsSeparatedByString:@"\n"];
        NSMutableArray *orderingRules = [NSMutableArray arrayWithCapacity:100];
        
        for (NSString *rawOrderingRule in rawOrderingRules) {
            NSArray *orderingRuleParts = [rawOrderingRule componentsSeparatedByString:@"|"];
            
            NSInteger before = [orderingRuleParts[0] integerValue];
            NSNumber *after = @([orderingRuleParts[1] integerValue]);
            
            if (orderingRules.count > before && orderingRules[before] != [NSNull null]) {
                [orderingRules[before] addObject:after];
            } else {
                // Ensure the array can hold the value at the specified index
                while (orderingRules.count <= before) {
                    [orderingRules addObject:[NSNull null]]; // Placeholder for unassigned indices
                }
                
                orderingRules[before] = [NSMutableArray arrayWithObject:after];
            }
        }
        
        for (NSString *rawUpdate in rawUpdates) {
            @autoreleasepool {
                NSArray *values = [rawUpdate componentsSeparatedByString:@","];
                NSMutableArray *seenPages = [NSMutableArray array];
                NSNumber *isBad = 0;
                
                for (NSString *rawValue in values) {
                    @autoreleasepool {
                        NSNumber *value = [f numberFromString:rawValue];
                        
                        if (value != nil && ![value isKindOfClass:[NSNull class]]) {
                            [seenPages addObject:value];
                            
                            if ([orderingRules objectAtIndex:[value integerValue]] != nil) {
                                NSArray *shouldBeBefores = [orderingRules objectAtIndex:[value integerValue]];
                                
                                if (shouldBeBefores != nil && ![shouldBeBefores isKindOfClass:[NSNull class]]) {
                                    for (NSNumber *shouldBeBefore in shouldBeBefores) {
                                        if ([seenPages containsObject:shouldBeBefore]) {
                                            isBad = @1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if (![isBad isEqual:@1] && rawUpdate != nil && ![rawUpdate isEqual:@""]) {
                    count = count + 1;
                    middleTotal = middleTotal + [seenPages[seenPages.count / 2] integerValue];
                }
            }
        }
        
        NSLog(@"count: %ld, middle total: %ld", count, middleTotal);
    }
    return 0;
}
