import { V8Coverage } from "collect-v8-coverage";
import { CoverageMap, CoverageMapData } from "istanbul-lib-coverage";
import { ConsoleBuffer } from "@jest/console";
import { Circus, Config, TransformTypes } from "@jest/types";
import { IHasteFS, IModuleMap } from "jest-haste-map";
import Resolver from "jest-resolve";

//#region src/types.d.ts

type RuntimeTransformResult = TransformTypes.TransformResult;
type V8CoverageResult = Array<{
  codeTransformResult: RuntimeTransformResult | undefined;
  result: V8Coverage[number];
}>;
type SerializableError = TestResult.SerializableError;
type FailedAssertion = {
  matcherName?: string;
  message?: string;
  actual?: unknown;
  pass?: boolean;
  passed?: boolean;
  expected?: unknown;
  isNot?: boolean;
  stack?: string;
  error?: unknown;
};
type AssertionLocation = {
  fullName: string;
  path: string;
};
type Status = AssertionResult['status'];
type AssertionResult = TestResult.AssertionResult;
type FormattedAssertionResult = Pick<AssertionResult, 'ancestorTitles' | 'fullName' | 'location' | 'status' | 'title' | 'duration'> & {
  failureMessages: AssertionResult['failureMessages'] | null;
};
type AggregatedResultWithoutCoverage = {
  numFailedTests: number;
  numFailedTestSuites: number;
  numPassedTests: number;
  numPassedTestSuites: number;
  numPendingTests: number;
  numTodoTests: number;
  numPendingTestSuites: number;
  numRuntimeErrorTestSuites: number;
  numTotalTests: number;
  numTotalTestSuites: number;
  openHandles: Array<Error>;
  snapshot: SnapshotSummary;
  startTime: number;
  success: boolean;
  testResults: Array<TestResult>;
  wasInterrupted: boolean;
  runExecError?: SerializableError;
};
type AggregatedResult = AggregatedResultWithoutCoverage & {
  coverageMap?: CoverageMap | null;
};
type TestResultsProcessor = (results: AggregatedResult) => AggregatedResult | Promise<AggregatedResult>;
type Suite = {
  title: string;
  suites: Array<Suite>;
  tests: Array<AssertionResult>;
};
type TestCaseResult = AssertionResult & {
  startedAt?: number | null;
};
type TestResult = {
  console?: ConsoleBuffer;
  coverage?: CoverageMapData;
  displayName?: Config.DisplayName;
  /**
   * Whether [`test.failing()`](https://jestjs.io/docs/api#testfailingname-fn-timeout)
   * was used.
   */
  failing?: boolean;
  failureMessage?: string | null;
  leaks: boolean;
  memoryUsage?: number;
  numFailingTests: number;
  numPassingTests: number;
  numPendingTests: number;
  numTodoTests: number;
  openHandles: Array<Error>;
  perfStats: {
    end: number;
    loadTestEnvironmentEnd: number;
    loadTestEnvironmentStart: number;
    runtime: number;
    setupAfterEnvEnd: number;
    setupAfterEnvStart: number;
    setupFilesEnd: number;
    setupFilesStart: number;
    slow: boolean;
    start: number;
  };
  skipped: boolean;
  snapshot: {
    added: number;
    fileDeleted: boolean;
    matched: number;
    unchecked: number;
    uncheckedKeys: Array<string>;
    unmatched: number;
    updated: number;
  };
  testExecError?: SerializableError;
  testFilePath: string;
  testResults: Array<AssertionResult>;
  v8Coverage?: V8CoverageResult;
};
type FormattedTestResult = {
  message: string;
  name: string;
  summary: string;
  status: 'failed' | 'passed' | 'skipped' | 'focused';
  startTime: number;
  endTime: number;
  coverage: unknown;
  assertionResults: Array<FormattedAssertionResult>;
};
type FormattedTestResults = {
  coverageMap?: CoverageMap | null | undefined;
  numFailedTests: number;
  numFailedTestSuites: number;
  numPassedTests: number;
  numPassedTestSuites: number;
  numPendingTests: number;
  numPendingTestSuites: number;
  numRuntimeErrorTestSuites: number;
  numTotalTests: number;
  numTotalTestSuites: number;
  snapshot: SnapshotSummary;
  startTime: number;
  success: boolean;
  testResults: Array<FormattedTestResult>;
  wasInterrupted: boolean;
};
type CodeCoverageReporter = unknown;
type CodeCoverageFormatter = (coverage: CoverageMapData | null | undefined, reporter: CodeCoverageReporter) => Record<string, unknown> | null | undefined;
type UncheckedSnapshot = {
  filePath: string;
  keys: Array<string>;
};
type SnapshotSummary = {
  added: number;
  didUpdate: boolean;
  failure: boolean;
  filesAdded: number;
  filesRemoved: number;
  filesRemovedList: Array<string>;
  filesUnmatched: number;
  filesUpdated: number;
  matched: number;
  total: number;
  unchecked: number;
  uncheckedKeysByFile: Array<UncheckedSnapshot>;
  unmatched: number;
  updated: number;
};
type Test = {
  context: TestContext;
  duration?: number;
  path: string;
};
type TestContext = {
  config: Config.ProjectConfig;
  hasteFS: IHasteFS;
  moduleMap: IModuleMap;
  resolver: Resolver;
};
type TestEvents = {
  'test-file-start': [Test];
  'test-file-success': [Test, TestResult];
  'test-file-failure': [Test, SerializableError];
  'test-case-start': [string, Circus.TestCaseStartInfo];
  'test-case-result': [string, TestCaseResult];
};
type TestFileEvent<T extends keyof TestEvents = keyof TestEvents> = (eventName: T, args: TestEvents[T]) => unknown;
//#endregion
//#region src/formatTestResults.d.ts
declare function formatTestResults(results: AggregatedResult, codeCoverageFormatter?: CodeCoverageFormatter, reporter?: CodeCoverageReporter): FormattedTestResults;
//#endregion
//#region src/helpers.d.ts
declare const makeEmptyAggregatedTestResult: () => AggregatedResult;
declare const buildFailureTestResult: (testPath: string, err: SerializableError) => TestResult;
declare const addResult: (aggregatedResults: AggregatedResult, testResult: TestResult) => void;
declare const createEmptyTestResult: () => TestResult;
//#endregion
export { AggregatedResult, AssertionLocation, AssertionResult, FailedAssertion, FormattedTestResults, RuntimeTransformResult, SerializableError, SnapshotSummary, Status, Suite, Test, TestCaseResult, TestContext, TestEvents, TestFileEvent, TestResult, TestResultsProcessor, V8CoverageResult, addResult, buildFailureTestResult, createEmptyTestResult, formatTestResults, makeEmptyAggregatedTestResult };