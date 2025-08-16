import * as ProcessModule from "process";
import { CoverageMapData } from "istanbul-lib-coverage";
import { ForegroundColor } from "chalk";
import { ReportOptions } from "istanbul-reports";
import { Arguments } from "yargs";
import { TestPathPatterns } from "@jest/pattern";
import { InitialOptions, InitialOptions as InitialOptions$1, SnapshotFormat } from "@jest/schemas";

//#region rolldown:runtime
declare namespace Global_d_exports {
  export { ArrayTable, BlockFn$1 as BlockFn, BlockName$1 as BlockName, BlockNameLike$1 as BlockNameLike, Col, ConcurrentTestFn$1 as ConcurrentTestFn, Describe, DescribeBase, DoneFn$1 as DoneFn, DoneTakingTestFn, EachTable, EachTestFn, Failing, GeneratorReturningTestFn, Global, GlobalAdditions, HookBase, HookFn$1 as HookFn, It, ItBase, ItConcurrent, ItConcurrentBase, ItConcurrentExtended, NameLike, PromiseReturningTestFn, Row, Table, TemplateData, TemplateTable, TestCallback, TestContext$1 as TestContext, TestFn$1 as TestFn, TestFrameworkGlobals, TestName$1 as TestName, TestNameLike$1 as TestNameLike, TestReturnValue, ValidTestReturnValues };
}
type ValidTestReturnValues = void | undefined;
type TestReturnValuePromise = Promise<unknown>;
type TestReturnValueGenerator = Generator<void, unknown, void>;
type TestReturnValue = ValidTestReturnValues | TestReturnValuePromise;
type TestContext$1 = Record<string, unknown>;
type DoneFn$1 = (reason?: string | Error) => void;
type DoneTakingTestFn = (this: TestContext$1, done: DoneFn$1) => ValidTestReturnValues;
type PromiseReturningTestFn = (this: TestContext$1) => TestReturnValue;
type GeneratorReturningTestFn = (this: TestContext$1) => TestReturnValueGenerator;
type NameLike = number | Function;
type TestName$1 = string;
type TestNameLike$1 = TestName$1 | NameLike;
type TestFn$1 = PromiseReturningTestFn | GeneratorReturningTestFn | DoneTakingTestFn;
type ConcurrentTestFn$1 = () => TestReturnValuePromise;
type BlockFn$1 = () => void;
type BlockName$1 = string;
type BlockNameLike$1 = BlockName$1 | NameLike;
type HookFn$1 = TestFn$1;
type Col = unknown;
type Row = ReadonlyArray<Col>;
type Table = ReadonlyArray<Row>;
type ArrayTable = Table | Row;
type TemplateTable = TemplateStringsArray;
type TemplateData = ReadonlyArray<unknown>;
type EachTable = ArrayTable | TemplateTable;
type TestCallback = BlockFn$1 | TestFn$1 | ConcurrentTestFn$1;
type EachTestFn<EachCallback extends TestCallback> = (...args: ReadonlyArray<any>) => ReturnType<EachCallback>;
interface Each<EachFn extends TestFn$1 | BlockFn$1> {
  <T extends Record<string, unknown>>(table: ReadonlyArray<T>): (name: string | NameLike, fn: (arg: T, done: DoneFn$1) => ReturnType<EachFn>, timeout?: number) => void;
  <T extends readonly [unknown, ...Array<unknown>]>(table: ReadonlyArray<T>): (name: string | NameLike, fn: (...args: [...T]) => ReturnType<EachFn>, timeout?: number) => void;
  <T extends ReadonlyArray<unknown>>(table: ReadonlyArray<T>): (name: string | NameLike, fn: (...args: T) => ReturnType<EachFn>, timeout?: number) => void;
  <T>(table: ReadonlyArray<T>): (name: string | NameLike, fn: (arg: T, done: DoneFn$1) => ReturnType<EachFn>, timeout?: number) => void;
  <T extends Array<unknown>>(strings: TemplateStringsArray, ...expressions: T): (name: string | NameLike, fn: (arg: Record<string, T[number]>, done: DoneFn$1) => ReturnType<EachFn>, timeout?: number) => void;
  <T extends Record<string, unknown>>(strings: TemplateStringsArray, ...expressions: Array<unknown>): (name: string | NameLike, fn: (arg: T, done: DoneFn$1) => ReturnType<EachFn>, timeout?: number) => void;
}
type HookBase = (fn: HookFn$1, timeout?: number) => void;
interface Failing<T extends TestFn$1> {
  (testName: TestNameLike$1, fn: T, timeout?: number): void;
  each: Each<T>;
}
interface ItBase {
  (testName: TestNameLike$1, fn: TestFn$1, timeout?: number): void;
  each: Each<TestFn$1>;
  failing: Failing<TestFn$1>;
}
interface It extends ItBase {
  only: ItBase;
  skip: ItBase;
  todo: (testName: TestNameLike$1) => void;
}
interface ItConcurrentBase {
  (testName: TestNameLike$1, testFn: ConcurrentTestFn$1, timeout?: number): void;
  each: Each<ConcurrentTestFn$1>;
  failing: Failing<ConcurrentTestFn$1>;
}
interface ItConcurrentExtended extends ItConcurrentBase {
  only: ItConcurrentBase;
  skip: ItConcurrentBase;
}
interface ItConcurrent extends It {
  concurrent: ItConcurrentExtended;
}
interface DescribeBase {
  (blockName: BlockNameLike$1, blockFn: BlockFn$1): void;
  each: Each<BlockFn$1>;
}
interface Describe extends DescribeBase {
  only: DescribeBase;
  skip: DescribeBase;
}
interface TestFrameworkGlobals {
  it: ItConcurrent;
  test: ItConcurrent;
  fit: ItBase & {
    concurrent?: ItConcurrentBase;
  };
  xit: ItBase;
  xtest: ItBase;
  describe: Describe;
  xdescribe: DescribeBase;
  fdescribe: DescribeBase;
  beforeAll: HookBase;
  beforeEach: HookBase;
  afterEach: HookBase;
  afterAll: HookBase;
}
interface GlobalAdditions extends TestFrameworkGlobals {
  __coverage__: CoverageMapData;
}
interface Global extends GlobalAdditions, Omit<typeof globalThis, keyof GlobalAdditions> {
  [extras: PropertyKey]: unknown;
}
declare namespace Circus_d_exports {
  export { AsyncEvent, AsyncFn, BlockFn, BlockMode, BlockName, BlockNameLike, ConcurrentTestFn, DescribeBlock, DoneFn, Event, EventHandler, Exception, FormattedError, GlobalErrorHandlers, Hook, HookFn, HookType, MatcherResults, RunResult, SharedHookType, State, SyncEvent, TestCaseStartInfo, TestContext, TestEntry, TestError, TestFn, TestMode, TestName, TestNameLike, TestNamesPath, TestResult, TestResults, TestStatus };
}
type Process = typeof ProcessModule;
type DoneFn = DoneFn$1;
type BlockFn = BlockFn$1;
type BlockName = BlockName$1;
type BlockNameLike = BlockNameLike$1;
type BlockMode = void | 'skip' | 'only' | 'todo';
type TestMode = BlockMode;
type TestName = TestName$1;
type TestNameLike = TestNameLike$1;
type TestFn = TestFn$1;
type ConcurrentTestFn = ConcurrentTestFn$1;
type HookFn = HookFn$1;
type AsyncFn = TestFn | HookFn;
type SharedHookType = 'afterAll' | 'beforeAll';
type HookType = SharedHookType | 'afterEach' | 'beforeEach';
type TestContext = TestContext$1;
type Exception = any;
type FormattedError = string;
type Hook = {
  asyncError: Error;
  fn: HookFn;
  type: HookType;
  parent: DescribeBlock;
  seenDone: boolean;
  timeout: number | undefined | null;
};
interface EventHandler {
  (event: AsyncEvent, state: State): void | Promise<void>;
  (event: SyncEvent, state: State): void;
}
type Event = SyncEvent | AsyncEvent;
interface JestGlobals extends TestFrameworkGlobals {
  expect: unknown;
}
type SyncEvent = {
  asyncError: Error;
  mode: BlockMode;
  name: 'start_describe_definition';
  blockName: BlockName;
} | {
  mode: BlockMode;
  name: 'finish_describe_definition';
  blockName: BlockName;
} | {
  asyncError: Error;
  name: 'add_hook';
  hookType: HookType;
  fn: HookFn;
  timeout: number | undefined;
} | {
  asyncError: Error;
  name: 'add_test';
  testName: TestName;
  fn: TestFn;
  mode?: TestMode;
  concurrent: boolean;
  timeout: number | undefined;
  failing: boolean;
} | {
  name: 'error';
  error: Exception;
  promise?: Promise<unknown>;
} | {
  name: 'error_handled';
  promise: Promise<unknown>;
};
type AsyncEvent = {
  name: 'setup';
  testNamePattern?: string;
  runtimeGlobals: JestGlobals;
  parentProcess: Process;
} | {
  name: 'include_test_location_in_result';
} | {
  name: 'hook_start';
  hook: Hook;
} | {
  name: 'hook_success';
  describeBlock?: DescribeBlock;
  test?: TestEntry;
  hook: Hook;
} | {
  name: 'hook_failure';
  error: string | Exception;
  describeBlock?: DescribeBlock;
  test?: TestEntry;
  hook: Hook;
} | {
  name: 'test_fn_start';
  test: TestEntry;
} | {
  name: 'test_fn_success';
  test: TestEntry;
} | {
  name: 'test_fn_failure';
  error: Exception;
  test: TestEntry;
} | {
  name: 'test_retry';
  test: TestEntry;
} | {
  name: 'test_start';
  test: TestEntry;
} | {
  name: 'test_skip';
  test: TestEntry;
} | {
  name: 'test_todo';
  test: TestEntry;
} | {
  name: 'test_started';
  test: TestEntry;
} | {
  name: 'test_done';
  test: TestEntry;
} | {
  name: 'run_describe_start';
  describeBlock: DescribeBlock;
} | {
  name: 'run_describe_finish';
  describeBlock: DescribeBlock;
} | {
  name: 'run_start';
} | {
  name: 'run_finish';
} | {
  name: 'teardown';
};
type MatcherResults = {
  actual: unknown;
  expected: unknown;
  name: string;
  pass: boolean;
};
type TestStatus = 'skip' | 'done' | 'todo';
type TestNamesPath = Array<TestName | BlockName>;
type TestCaseStartInfo = {
  ancestorTitles: Array<string>;
  fullName: string;
  mode: TestMode;
  title: string;
  startedAt?: number | null;
};
type TestResult = {
  duration?: number | null;
  errors: Array<FormattedError>;
  errorsDetailed: Array<MatcherResults | unknown>;
  /**
   * Whether [`test.failing()`](https://jestjs.io/docs/api#testfailingname-fn-timeout)
   * was used.
   */
  failing?: boolean;
  invocations: number;
  startedAt?: number | null;
  status: TestStatus;
  location?: {
    column: number;
    line: number;
  } | null;
  numPassingAsserts: number;
  retryReasons: Array<FormattedError>;
  testPath: TestNamesPath;
};
type RunResult = {
  unhandledErrors: Array<FormattedError>;
  testResults: TestResults;
};
type TestResults = Array<TestResult>;
type GlobalErrorHandlers = {
  rejectionHandled: Array<(promise: Promise<unknown>) => void>;
  uncaughtException: Array<NodeJS.UncaughtExceptionListener>;
  unhandledRejection: Array<NodeJS.UnhandledRejectionListener>;
};
type State = {
  currentDescribeBlock: DescribeBlock;
  currentlyRunningTest?: TestEntry | null;
  expand?: boolean;
  hasFocusedTests: boolean;
  hasStarted: boolean;
  originalGlobalErrorHandlers?: GlobalErrorHandlers;
  parentProcess: Process | null;
  randomize?: boolean;
  rootDescribeBlock: DescribeBlock;
  seed: number;
  testNamePattern?: RegExp | null;
  testTimeout: number;
  unhandledErrors: Array<Exception>;
  includeTestLocationInResult: boolean;
  maxConcurrency: number;
  unhandledRejectionErrorByPromise: Map<Promise<unknown>, Exception>;
};
type DescribeBlock = {
  type: 'describeBlock';
  children: Array<DescribeBlock | TestEntry>;
  hooks: Array<Hook>;
  mode: BlockMode;
  name: BlockName;
  parent?: DescribeBlock;
  /** @deprecated Please get from `children` array instead */
  tests: Array<TestEntry>;
};
type TestError = Exception | [Exception | undefined, Exception];
type TestEntry = {
  type: 'test';
  asyncError: Exception;
  errors: Array<TestError>;
  retryReasons: Array<TestError>;
  fn: TestFn;
  invocations: number;
  mode: TestMode;
  concurrent: boolean;
  name: TestName;
  numPassingAsserts: number;
  parent: DescribeBlock;
  startedAt?: number | null;
  duration?: number | null;
  seenDone: boolean;
  status?: TestStatus | null;
  timeout?: number;
  failing: boolean;
  unhandledRejectionErrorByPromise: Map<Promise<unknown>, Exception>;
};
declare namespace Config_d_exports {
  export { Argv, ConfigGlobals, CoverageReporterName, CoverageReporterWithOptions, CoverageReporters, CoverageThresholdValue, DefaultOptions, DisplayName, FakeTimersConfig, FakeableAPI, GlobalConfig, GlobalFakeTimersConfig, HasteConfig, InitialOptions$1 as InitialOptions, InitialOptionsWithRootDir, InitialProjectOptions, LegacyFakeTimersConfig, ProjectConfig, ReporterConfig, SetupAfterEnvPerfStats, SnapshotUpdateState, TransformerConfig };
}
type CoverageProvider = 'babel' | 'v8';
type FakeableAPI = 'Date' | 'hrtime' | 'nextTick' | 'performance' | 'queueMicrotask' | 'requestAnimationFrame' | 'cancelAnimationFrame' | 'requestIdleCallback' | 'cancelIdleCallback' | 'setImmediate' | 'clearImmediate' | 'setInterval' | 'clearInterval' | 'setTimeout' | 'clearTimeout';
type GlobalFakeTimersConfig = {
  /**
   * Whether fake timers should be enabled globally for all test files.
   *
   * @defaultValue
   * The default is `false`.
   */
  enableGlobally?: boolean;
};
type FakeTimersConfig = {
  /**
   * If set to `true` all timers will be advanced automatically
   * by 20 milliseconds every 20 milliseconds. A custom time delta
   * may be provided by passing a number.
   *
   * @defaultValue
   * The default is `false`.
   */
  advanceTimers?: boolean | number;
  /**
   * List of names of APIs (e.g. `Date`, `nextTick()`, `setImmediate()`,
   * `setTimeout()`) that should not be faked.
   *
   * @defaultValue
   * The default is `[]`, meaning all APIs are faked.
   */
  doNotFake?: Array<FakeableAPI>;
  /**
   * Sets current system time to be used by fake timers, in milliseconds.
   *
   * @defaultValue
   * The default is `Date.now()`.
   */
  now?: number | Date;
  /**
   * The maximum number of recursive timers that will be run when calling
   * `jest.runAllTimers()`.
   *
   * @defaultValue
   * The default is `100_000` timers.
   */
  timerLimit?: number;
  /**
   * Use the old fake timers implementation instead of one backed by
   * [`@sinonjs/fake-timers`](https://github.com/sinonjs/fake-timers).
   *
   * @defaultValue
   * The default is `false`.
   */
  legacyFakeTimers?: false;
};
type LegacyFakeTimersConfig = {
  /**
   * Use the old fake timers implementation instead of one backed by
   * [`@sinonjs/fake-timers`](https://github.com/sinonjs/fake-timers).
   *
   * @defaultValue
   * The default is `false`.
   */
  legacyFakeTimers?: true;
};
type FakeTimers = GlobalFakeTimersConfig & ((FakeTimersConfig & {
  now?: Exclude<FakeTimersConfig['now'], Date>;
}) | LegacyFakeTimersConfig);
type HasteConfig = {
  /** Whether to hash files using SHA-1. */
  computeSha1?: boolean;
  /** The platform to use as the default, e.g. 'ios'. */
  defaultPlatform?: string | null;
  /** Force use of Node's `fs` APIs rather than shelling out to `find` */
  forceNodeFilesystemAPI?: boolean;
  /**
   * Whether to follow symlinks when crawling for files.
   *   This options cannot be used in projects which use watchman.
   *   Projects with `watchman` set to true will error if this option is set to true.
   */
  enableSymlinks?: boolean;
  /** string to a custom implementation of Haste. */
  hasteImplModulePath?: string;
  /** All platforms to target, e.g ['ios', 'android']. */
  platforms?: Array<string>;
  /** Whether to throw an error on module collision. */
  throwOnModuleCollision?: boolean;
  /** Custom HasteMap module */
  hasteMapModulePath?: string;
  /** Whether to retain all files, allowing e.g. search for tests in `node_modules`. */
  retainAllFiles?: boolean;
};
type CoverageReporterName = keyof ReportOptions;
type CoverageReporterWithOptions<K = CoverageReporterName> = K extends CoverageReporterName ? ReportOptions[K] extends never ? never : [K, Partial<ReportOptions[K]>] : never;
type CoverageReporters = Array<CoverageReporterName | CoverageReporterWithOptions>;
type ReporterConfig = [string, Record<string, unknown>];
type TransformerConfig = [string, Record<string, unknown>];
interface ConfigGlobals {
  [K: string]: unknown;
}
type DefaultOptions = {
  automock: boolean;
  bail: number;
  cache: boolean;
  cacheDirectory: string;
  changedFilesWithAncestor: boolean;
  ci: boolean;
  clearMocks: boolean;
  collectCoverage: boolean;
  coveragePathIgnorePatterns: Array<string>;
  coverageReporters: Array<CoverageReporterName>;
  coverageProvider: CoverageProvider;
  detectLeaks: boolean;
  detectOpenHandles: boolean;
  errorOnDeprecated: boolean;
  expand: boolean;
  extensionsToTreatAsEsm: Array<string>;
  fakeTimers: FakeTimers;
  forceCoverageMatch: Array<string>;
  globals: ConfigGlobals;
  haste: HasteConfig;
  injectGlobals: boolean;
  listTests: boolean;
  maxConcurrency: number;
  maxWorkers: number | string;
  moduleDirectories: Array<string>;
  moduleFileExtensions: Array<string>;
  moduleNameMapper: Record<string, string | Array<string>>;
  modulePathIgnorePatterns: Array<string>;
  noStackTrace: boolean;
  notify: boolean;
  notifyMode: NotifyMode;
  openHandlesTimeout: number;
  passWithNoTests: boolean;
  prettierPath: string;
  resetMocks: boolean;
  resetModules: boolean;
  restoreMocks: boolean;
  roots: Array<string>;
  runTestsByPath: boolean;
  runner: string;
  setupFiles: Array<string>;
  setupFilesAfterEnv: Array<string>;
  skipFilter: boolean;
  slowTestThreshold: number;
  snapshotFormat: SnapshotFormat;
  snapshotSerializers: Array<string>;
  testEnvironment: string;
  testEnvironmentOptions: Record<string, unknown>;
  testFailureExitCode: number;
  testLocationInResults: boolean;
  testMatch: Array<string>;
  testPathIgnorePatterns: Array<string>;
  testRegex: Array<string>;
  testRunner: string;
  testSequencer: string;
  transformIgnorePatterns: Array<string>;
  useStderr: boolean;
  waitForUnhandledRejections: boolean;
  watch: boolean;
  watchPathIgnorePatterns: Array<string>;
  watchman: boolean;
  workerThreads: boolean;
};
type DisplayName = {
  name: string;
  color: typeof ForegroundColor;
};
type InitialOptionsWithRootDir = InitialOptions & Required<Pick<InitialOptions, 'rootDir'>>;
type InitialProjectOptions = Pick<InitialOptions & {
  cwd?: string;
}, keyof ProjectConfig>;
type SnapshotUpdateState = 'all' | 'new' | 'none';
type NotifyMode = 'always' | 'failure' | 'success' | 'change' | 'success-change' | 'failure-change';
type CoverageThresholdValue = {
  branches?: number;
  functions?: number;
  lines?: number;
  statements?: number;
};
type CoverageThreshold = {
  [path: string]: CoverageThresholdValue;
  global: CoverageThresholdValue;
};
type ShardConfig = {
  shardIndex: number;
  shardCount: number;
};
type GlobalConfig = {
  bail: number;
  changedSince?: string;
  changedFilesWithAncestor: boolean;
  ci: boolean;
  collectCoverage: boolean;
  collectCoverageFrom: Array<string>;
  coverageDirectory: string;
  coveragePathIgnorePatterns?: Array<string>;
  coverageProvider: CoverageProvider;
  coverageReporters: CoverageReporters;
  coverageThreshold?: CoverageThreshold;
  detectLeaks: boolean;
  detectOpenHandles: boolean;
  expand: boolean;
  filter?: string;
  findRelatedTests: boolean;
  forceExit: boolean;
  json: boolean;
  globalSetup?: string;
  globalTeardown?: string;
  lastCommit: boolean;
  logHeapUsage: boolean;
  listTests: boolean;
  maxConcurrency: number;
  maxWorkers: number;
  noStackTrace: boolean;
  nonFlagArgs: Array<string>;
  noSCM?: boolean;
  notify: boolean;
  notifyMode: NotifyMode;
  outputFile?: string;
  onlyChanged: boolean;
  onlyFailures: boolean;
  openHandlesTimeout: number;
  passWithNoTests: boolean;
  projects: Array<string>;
  randomize?: boolean;
  replname?: string;
  reporters?: Array<ReporterConfig>;
  runInBand: boolean;
  runTestsByPath: boolean;
  rootDir: string;
  seed: number;
  showSeed?: boolean;
  shard?: ShardConfig;
  silent?: boolean;
  skipFilter: boolean;
  snapshotFormat: SnapshotFormat;
  errorOnDeprecated: boolean;
  testFailureExitCode: number;
  testNamePattern?: string;
  testPathPatterns: TestPathPatterns;
  testResultsProcessor?: string;
  testSequencer: string;
  testTimeout?: number;
  updateSnapshot: SnapshotUpdateState;
  useStderr: boolean;
  verbose?: boolean;
  waitForUnhandledRejections: boolean;
  watch: boolean;
  watchAll: boolean;
  watchman: boolean;
  watchPlugins?: Array<{
    path: string;
    config: Record<string, unknown>;
  }> | null;
  workerIdleMemoryLimit?: number;
  workerThreads?: boolean;
};
type ProjectConfig = {
  automock: boolean;
  cache: boolean;
  cacheDirectory: string;
  clearMocks: boolean;
  collectCoverageFrom: Array<string>;
  coverageDirectory: string;
  coveragePathIgnorePatterns: Array<string>;
  coverageReporters: CoverageReporters;
  cwd: string;
  dependencyExtractor?: string;
  detectLeaks: boolean;
  detectOpenHandles: boolean;
  displayName?: DisplayName;
  errorOnDeprecated: boolean;
  extensionsToTreatAsEsm: Array<string>;
  fakeTimers: FakeTimers;
  filter?: string;
  forceCoverageMatch: Array<string>;
  globalSetup?: string;
  globalTeardown?: string;
  globals: ConfigGlobals;
  haste: HasteConfig;
  id: string;
  injectGlobals: boolean;
  moduleDirectories: Array<string>;
  moduleFileExtensions: Array<string>;
  moduleNameMapper: Array<[string, string]>;
  modulePathIgnorePatterns: Array<string>;
  modulePaths?: Array<string>;
  openHandlesTimeout: number;
  preset?: string;
  prettierPath: string;
  reporters: Array<string | ReporterConfig>;
  resetMocks: boolean;
  resetModules: boolean;
  resolver?: string;
  restoreMocks: boolean;
  rootDir: string;
  roots: Array<string>;
  runner: string;
  runtime?: string;
  sandboxInjectedGlobals: Array<keyof typeof globalThis>;
  setupFiles: Array<string>;
  setupFilesAfterEnv: Array<string>;
  skipFilter: boolean;
  skipNodeResolution?: boolean;
  slowTestThreshold: number;
  snapshotResolver?: string;
  snapshotSerializers: Array<string>;
  snapshotFormat: SnapshotFormat;
  testEnvironment: string;
  testEnvironmentOptions: Record<string, unknown>;
  testMatch: Array<string>;
  testLocationInResults: boolean;
  testPathIgnorePatterns: Array<string>;
  testRegex: Array<string | RegExp>;
  testRunner: string;
  testTimeout: number;
  transform: Array<[string, string, Record<string, unknown>]>;
  transformIgnorePatterns: Array<string>;
  watchPathIgnorePatterns: Array<string>;
  unmockedModulePathPatterns?: Array<string>;
  waitForUnhandledRejections: boolean;
  workerIdleMemoryLimit?: number;
};
type SetupAfterEnvPerfStats = {
  setupAfterEnvStart: number;
  setupAfterEnvEnd: number;
};
type Argv = Arguments<Partial<{
  all: boolean;
  automock: boolean;
  bail: boolean | number;
  cache: boolean;
  cacheDirectory: string;
  changedFilesWithAncestor: boolean;
  changedSince: string;
  ci: boolean;
  clearCache: boolean;
  clearMocks: boolean;
  collectCoverage: boolean;
  collectCoverageFrom: string;
  color: boolean;
  colors: boolean;
  config: string;
  coverage: boolean;
  coverageDirectory: string;
  coveragePathIgnorePatterns: Array<string>;
  coverageReporters: Array<string>;
  coverageThreshold: string;
  debug: boolean;
  env: string;
  expand: boolean;
  findRelatedTests: boolean;
  forceExit: boolean;
  globals: string;
  globalSetup: string | null | undefined;
  globalTeardown: string | null | undefined;
  haste: string;
  ignoreProjects: Array<string>;
  injectGlobals: boolean;
  json: boolean;
  lastCommit: boolean;
  logHeapUsage: boolean;
  maxWorkers: number | string;
  moduleDirectories: Array<string>;
  moduleFileExtensions: Array<string>;
  moduleNameMapper: string;
  modulePathIgnorePatterns: Array<string>;
  modulePaths: Array<string>;
  noStackTrace: boolean;
  notify: boolean;
  notifyMode: string;
  onlyChanged: boolean;
  onlyFailures: boolean;
  outputFile: string;
  preset: string | null | undefined;
  prettierPath: string | null | undefined;
  projects: Array<string>;
  randomize: boolean;
  reporters: Array<string>;
  resetMocks: boolean;
  resetModules: boolean;
  resolver: string | null | undefined;
  restoreMocks: boolean;
  rootDir: string;
  roots: Array<string>;
  runInBand: boolean;
  seed: number;
  showSeed: boolean;
  selectProjects: Array<string>;
  setupFiles: Array<string>;
  setupFilesAfterEnv: Array<string>;
  shard: string;
  showConfig: boolean;
  silent: boolean;
  snapshotSerializers: Array<string>;
  testEnvironment: string;
  testEnvironmentOptions: string;
  testFailureExitCode: string | null | undefined;
  testMatch: Array<string>;
  testNamePattern: string;
  testPathIgnorePatterns: Array<string>;
  testPathPatterns: Array<string>;
  testRegex: string | Array<string>;
  testResultsProcessor: string;
  testRunner: string;
  testSequencer: string;
  testTimeout: number | null | undefined;
  transform: string;
  transformIgnorePatterns: Array<string>;
  unmockedModulePathPatterns: Array<string> | null | undefined;
  updateSnapshot: boolean;
  useStderr: boolean;
  verbose: boolean;
  version: boolean;
  watch: boolean;
  watchAll: boolean;
  watchman: boolean;
  watchPathIgnorePatterns: Array<string>;
  workerIdleMemoryLimit: number | string;
  workerThreads: boolean;
}>>;
declare namespace TestResult_d_exports {
  export { AssertionResult, SerializableError };
}
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
type Status = 'passed' | 'failed' | 'skipped' | 'pending' | 'todo' | 'disabled' | 'focused';
type Callsite = {
  column: number;
  line: number;
};
type AssertionResult = {
  ancestorTitles: Array<string>;
  duration?: number | null;
  startAt?: number | null;
  /**
   * Whether [`test.failing()`](https://jestjs.io/docs/api#testfailingname-fn-timeout)
   * was used.
   */
  failing?: boolean;
  /**
   * The raw values of the `function` or `symbol` types will be lost in some cases
   * because it's not possible to serialize them correctly between workers.
   * However, information about them will be available in the `failureMessages`.
   */
  failureDetails: Array<unknown>;
  failureMessages: Array<string>;
  fullName: string;
  invocations?: number;
  location?: Callsite | null;
  numPassingAsserts: number;
  retryReasons?: Array<string>;
  status: Status;
  title: string;
};
type SerializableError = {
  code?: unknown;
  message: string;
  stack: string | null | undefined;
  type?: string;
};
declare namespace Transform_d_exports {
  export { TransformResult };
}
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
type TransformResult = {
  code: string;
  originalCode: string;
  sourceMapPath: string | null;
};
//#endregion
export { Circus_d_exports as Circus, Config_d_exports as Config, Global_d_exports as Global, TestResult_d_exports as TestResult, Transform_d_exports as TransformTypes };