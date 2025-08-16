import { StackData } from "stack-utils";
import { Config, TestResult } from "@jest/types";

//#region src/types.d.ts

interface Frame extends StackData {
  file: string;
}
//#endregion
//#region src/index.d.ts

type StackTraceConfig = Pick<Config.ProjectConfig, 'rootDir' | 'testMatch'>;
type StackTraceOptions = {
  noStackTrace: boolean;
  noCodeFrame?: boolean;
};
declare const indentAllLines: (lines: string) => string;
declare const formatExecError: (error: Error | TestResult.SerializableError | string | number | undefined, config: StackTraceConfig, options: StackTraceOptions, testPath?: string, reuseMessage?: boolean, noTitle?: boolean) => string;
declare const formatPath: (line: string, config: StackTraceConfig, relativeTestPath?: string | null) => string;
declare function getStackTraceLines(stack: string, options?: StackTraceOptions): Array<string>;
declare function getTopFrame(lines: Array<string>): Frame | null;
declare function formatStackTrace(stack: string, config: StackTraceConfig, options: StackTraceOptions, testPath?: string): string;
declare const formatResultsErrors: (testResults: Array<TestResult.AssertionResult>, config: StackTraceConfig, options: StackTraceOptions, testPath?: string) => string | null;
declare const separateMessageFromStack: (content: string) => {
  message: string;
  stack: string;
};
//#endregion
export { Frame, StackTraceConfig, StackTraceOptions, formatExecError, formatPath, formatResultsErrors, formatStackTrace, getStackTraceLines, getTopFrame, indentAllLines, separateMessageFromStack };