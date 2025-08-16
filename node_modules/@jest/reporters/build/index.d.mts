import { Circus, Config, Config as Config$1 } from "@jest/types";
import { AggregatedResult, AggregatedResult as AggregatedResult$1, AssertionResult, SnapshotSummary, SnapshotSummary as SnapshotSummary$1, Suite, Test, Test as Test$1, TestCaseResult, TestCaseResult as TestCaseResult$1, TestContext, TestContext as TestContext$1, TestResult, TestResult as TestResult$1 } from "@jest/test-result";
import { WriteStream } from "tty";

//#region src/formatTestPath.d.ts

declare function formatTestPath(config: Config$1.GlobalConfig | Config$1.ProjectConfig, testPath: string): string;
//#endregion
//#region src/getResultHeader.d.ts
declare function getResultHeader(result: TestResult$1, globalConfig: Config$1.GlobalConfig, projectConfig?: Config$1.ProjectConfig): string;
//#endregion
//#region src/getSnapshotStatus.d.ts
declare function getSnapshotStatus(snapshot: TestResult$1['snapshot'], afterUpdate: boolean): Array<string>;
//#endregion
//#region src/getSnapshotSummary.d.ts
declare function getSnapshotSummary(snapshots: SnapshotSummary$1, globalConfig: Config$1.GlobalConfig, updateCommand: string): Array<string>;
//#endregion
//#region src/types.d.ts
type ReporterOnStartOptions = {
  estimatedTime: number;
  showStatus: boolean;
};
interface Reporter {
  readonly onTestResult?: (test: Test$1, testResult: TestResult$1, aggregatedResult: AggregatedResult$1) => Promise<void> | void;
  readonly onTestFileResult?: (test: Test$1, testResult: TestResult$1, aggregatedResult: AggregatedResult$1) => Promise<void> | void;
  /**
   * Called before running a spec (prior to `before` hooks)
   * Not called for `skipped` and `todo` specs
   */
  readonly onTestCaseStart?: (test: Test$1, testCaseStartInfo: Circus.TestCaseStartInfo) => Promise<void> | void;
  readonly onTestCaseResult?: (test: Test$1, testCaseResult: TestCaseResult$1) => Promise<void> | void;
  readonly onRunStart?: (results: AggregatedResult$1, options: ReporterOnStartOptions) => Promise<void> | void;
  readonly onTestStart?: (test: Test$1) => Promise<void> | void;
  readonly onTestFileStart?: (test: Test$1) => Promise<void> | void;
  readonly onRunComplete?: (testContexts: Set<TestContext$1>, results: AggregatedResult$1) => Promise<void> | void;
  readonly getLastError?: () => Error | void;
}
type ReporterContext = {
  firstRun: boolean;
  previousSuccess: boolean;
  changedFiles?: Set<string>;
  sourcesRelatedToTestsInChangedFiles?: Set<string>;
  startRun?: (globalConfig: Config$1.GlobalConfig) => unknown;
};
type SummaryOptions = {
  currentTestCases?: Array<{
    test: Test$1;
    testCaseResult: TestCaseResult$1;
  }>;
  estimatedTime?: number;
  roundTime?: boolean;
  width?: number;
  showSeed?: boolean;
  seed?: number;
};
//#endregion
//#region src/getSummary.d.ts
declare function getSummary(aggregatedResults: AggregatedResult$1, options?: SummaryOptions): string;
//#endregion
//#region src/printDisplayName.d.ts
declare function printDisplayName(config: Config$1.ProjectConfig): string;
//#endregion
//#region src/relativePath.d.ts
declare function relativePath(config: Config$1.GlobalConfig | Config$1.ProjectConfig, testPath: string): {
  basename: string;
  dirname: string;
};
//#endregion
//#region src/trimAndFormatPath.d.ts
declare function trimAndFormatPath(pad: number, config: Config$1.ProjectConfig | Config$1.GlobalConfig, testPath: string, columns: number): string;
//#endregion
//#region src/BaseReporter.d.ts
declare class BaseReporter implements Reporter {
  private _error?;
  log(message: string): void;
  onRunStart(_results?: AggregatedResult$1, _options?: ReporterOnStartOptions): void;
  onTestCaseResult(_test: Test$1, _testCaseResult: TestCaseResult$1): void;
  onTestResult(_test?: Test$1, _testResult?: TestResult$1, _results?: AggregatedResult$1): void;
  onTestStart(_test?: Test$1): void;
  onRunComplete(_testContexts?: Set<TestContext$1>, _aggregatedResults?: AggregatedResult$1): Promise<void> | void;
  protected _setError(error: Error): void;
  getLastError(): Error | undefined;
  protected __beginSynchronizedUpdate(write: WriteStream['write']): void;
  protected __endSynchronizedUpdate(write: WriteStream['write']): void;
}
//#endregion
//#region src/CoverageReporter.d.ts
declare class CoverageReporter extends BaseReporter {
  private readonly _context;
  private readonly _coverageMap;
  private readonly _globalConfig;
  private readonly _sourceMapStore;
  private readonly _v8CoverageResults;
  static readonly filename: string;
  constructor(globalConfig: Config$1.GlobalConfig, context: ReporterContext);
  onTestResult(_test: Test$1, testResult: TestResult$1): void;
  onRunComplete(testContexts: Set<TestContext$1>, aggregatedResults: AggregatedResult$1): Promise<void>;
  private _addUntestedFiles;
  private _checkThreshold;
  private _getCoverageResult;
}
//#endregion
//#region src/DefaultReporter.d.ts
declare class DefaultReporter extends BaseReporter {
  private _clear;
  private readonly _err;
  protected _globalConfig: Config$1.GlobalConfig;
  private readonly _out;
  private readonly _status;
  private readonly _bufferedOutput;
  static readonly filename: string;
  constructor(globalConfig: Config$1.GlobalConfig);
  protected __wrapStdio(stream: NodeJS.WritableStream | WriteStream): void;
  forceFlushBufferedOutput(): void;
  protected __clearStatus(): void;
  protected __printStatus(): void;
  onRunStart(aggregatedResults: AggregatedResult$1, options: ReporterOnStartOptions): void;
  onTestStart(test: Test$1): void;
  onTestCaseResult(test: Test$1, testCaseResult: TestCaseResult$1): void;
  onRunComplete(): void;
  onTestResult(test: Test$1, testResult: TestResult$1, aggregatedResults: AggregatedResult$1): void;
  testFinished(config: Config$1.ProjectConfig, testResult: TestResult$1, aggregatedResults: AggregatedResult$1): void;
  printTestFileHeader(testPath: string, config: Config$1.ProjectConfig, result: TestResult$1): void;
  printTestFileFailureMessage(_testPath: string, _config: Config$1.ProjectConfig, result: TestResult$1): void;
}
//#endregion
//#region src/GitHubActionsReporter.d.ts
declare class GitHubActionsReporter extends BaseReporter {
  #private;
  static readonly filename: string;
  private readonly options;
  constructor(_globalConfig: Config$1.GlobalConfig, reporterOptions?: {
    silent?: boolean;
  });
  onTestResult(test: Test$1, testResult: TestResult$1, aggregatedResults: AggregatedResult$1): void;
  private generateAnnotations;
  private isLastTestSuite;
  private printFullResult;
  private arrayEqual;
  private arrayChild;
  private getResultTree;
  private getResultChildren;
  private printResultTree;
  private recursivePrintResultTree;
  private printFailedTestLogs;
  private startGroup;
  private endGroup;
}
//#endregion
//#region src/NotifyReporter.d.ts
declare class NotifyReporter extends BaseReporter {
  private readonly _notifier;
  private readonly _globalConfig;
  private readonly _context;
  static readonly filename: string;
  constructor(globalConfig: Config$1.GlobalConfig, context: ReporterContext);
  onRunComplete(testContexts: Set<TestContext$1>, result: AggregatedResult$1): void;
}
//#endregion
//#region src/SummaryReporter.d.ts
type SummaryReporterOptions = {
  summaryThreshold?: number;
};
declare class SummaryReporter extends BaseReporter {
  private _estimatedTime;
  private readonly _globalConfig;
  private readonly _summaryThreshold;
  static readonly filename: string;
  constructor(globalConfig: Config$1.GlobalConfig, options?: SummaryReporterOptions);
  private _validateOptions;
  private _write;
  onRunStart(aggregatedResults: AggregatedResult$1, options: ReporterOnStartOptions): void;
  onRunComplete(testContexts: Set<TestContext$1>, aggregatedResults: AggregatedResult$1): void;
  private _printSnapshotSummary;
  private _printSummary;
  private _getTestSummary;
}
//#endregion
//#region src/VerboseReporter.d.ts
declare class VerboseReporter extends DefaultReporter {
  protected _globalConfig: Config$1.GlobalConfig;
  static readonly filename: string;
  constructor(globalConfig: Config$1.GlobalConfig);
  protected __wrapStdio(stream: NodeJS.WritableStream | WriteStream): void;
  static filterTestResults(testResults: Array<AssertionResult>): Array<AssertionResult>;
  static groupTestsBySuites(testResults: Array<AssertionResult>): Suite;
  onTestResult(test: Test$1, result: TestResult$1, aggregatedResults: AggregatedResult$1): void;
  private _logTestResults;
  private _logSuite;
  private _getIcon;
  private _logTest;
  private _logTests;
  private _logTodoOrPendingTest;
  private _logLine;
}
//#endregion
//#region src/index.d.ts
declare const utils: {
  formatTestPath: typeof formatTestPath;
  getResultHeader: typeof getResultHeader;
  getSnapshotStatus: typeof getSnapshotStatus;
  getSnapshotSummary: typeof getSnapshotSummary;
  getSummary: typeof getSummary;
  printDisplayName: typeof printDisplayName;
  relativePath: typeof relativePath;
  trimAndFormatPath: typeof trimAndFormatPath;
};
//#endregion
export { AggregatedResult, BaseReporter, Config, CoverageReporter, DefaultReporter, GitHubActionsReporter, NotifyReporter, Reporter, ReporterContext, ReporterOnStartOptions, SnapshotSummary, SummaryOptions, SummaryReporter, SummaryReporterOptions, Test, TestCaseResult, TestContext, TestResult, VerboseReporter, utils };