import { Chalk } from "chalk";
import { DiffOptions as DiffOptions$1 } from "jest-diff";

//#region src/deepCyclicCopyReplaceable.d.ts

/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare const SERIALIZABLE_PROPERTIES: unique symbol;
//#endregion
//#region src/index.d.ts

type MatcherHintColor = (arg: string) => string;
type MatcherHintOptions = {
  comment?: string;
  expectedColor?: MatcherHintColor;
  isDirectExpectCall?: boolean;
  isNot?: boolean;
  promise?: string;
  receivedColor?: MatcherHintColor;
  secondArgument?: string;
  secondArgumentColor?: MatcherHintColor;
};
type DiffOptions = DiffOptions$1;
declare const EXPECTED_COLOR: Chalk;
declare const RECEIVED_COLOR: Chalk;
declare const INVERTED_COLOR: Chalk;
declare const BOLD_WEIGHT: Chalk;
declare const DIM_COLOR: Chalk;
declare const SUGGEST_TO_CONTAIN_EQUAL: string;
declare const stringify: (object: unknown, maxDepth?: number, maxWidth?: number) => string;
declare const highlightTrailingWhitespace: (text: string) => string;
declare const printReceived: (object: unknown) => string;
declare const printExpected: (value: unknown) => string;
declare function printWithType<T>(name: string, value: T, print: (value: T) => string): string;
declare const ensureNoExpected: (expected: unknown, matcherName: string, options?: MatcherHintOptions) => void;
/**
 * Ensures that `actual` is of type `number | bigint`
 */
declare const ensureActualIsNumber: (actual: unknown, matcherName: string, options?: MatcherHintOptions) => void;
/**
 * Ensures that `expected` is of type `number | bigint`
 */
declare const ensureExpectedIsNumber: (expected: unknown, matcherName: string, options?: MatcherHintOptions) => void;
/**
 * Ensures that `actual` & `expected` are of type `number | bigint`
 */
declare const ensureNumbers: (actual: unknown, expected: unknown, matcherName: string, options?: MatcherHintOptions) => void;
declare const ensureExpectedIsNonNegativeInteger: (expected: unknown, matcherName: string, options?: MatcherHintOptions) => void;
declare const printDiffOrStringify: (expected: unknown, received: unknown, expectedLabel: string, receivedLabel: string, expand: boolean) => string;
declare function replaceMatchedToAsymmetricMatcher(replacedExpected: unknown, replacedReceived: unknown, expectedCycles: Array<unknown>, receivedCycles: Array<unknown>): {
  replacedExpected: unknown;
  replacedReceived: unknown;
};
declare const diff: (a: unknown, b: unknown, options?: DiffOptions) => string | null;
declare const pluralize: (word: string, count: number) => string;
type PrintLabel = (string: string) => string;
declare const getLabelPrinter: (...strings: Array<string>) => PrintLabel;
declare const matcherErrorMessage: (hint: string, generic: string, specific?: string) => string;
declare const matcherHint: (matcherName: string, received?: string, expected?: string, options?: MatcherHintOptions) => string;
//#endregion
export { BOLD_WEIGHT, DIM_COLOR, DiffOptions, EXPECTED_COLOR, INVERTED_COLOR, MatcherHintOptions, RECEIVED_COLOR, SERIALIZABLE_PROPERTIES, SUGGEST_TO_CONTAIN_EQUAL, diff, ensureActualIsNumber, ensureExpectedIsNonNegativeInteger, ensureExpectedIsNumber, ensureNoExpected, ensureNumbers, getLabelPrinter, highlightTrailingWhitespace, matcherErrorMessage, matcherHint, pluralize, printDiffOrStringify, printExpected, printReceived, printWithType, replaceMatchedToAsymmetricMatcher, stringify };