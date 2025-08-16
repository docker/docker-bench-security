import "jest-runtime";
import { SerializableError, Test, Test as Test$1, TestEvents, TestEvents as TestEvents$1, TestResult } from "@jest/test-result";
import { TestWatcher, TestWatcher as TestWatcher$1 } from "jest-watcher";
import { Config, Config as Config$1 } from "@jest/types";

//#region src/types.d.ts

type OnTestStart = (test: Test$1) => Promise<void>;
type OnTestFailure = (test: Test$1, serializableError: SerializableError) => Promise<void>;
type OnTestSuccess = (test: Test$1, testResult: TestResult) => Promise<void>;
type TestRunnerOptions = {
  serial: boolean;
};
type TestRunnerContext = {
  changedFiles?: Set<string>;
  sourcesRelatedToTestsInChangedFiles?: Set<string>;
};
type UnsubscribeFn = () => void;
interface CallbackTestRunnerInterface {
  readonly isSerial?: boolean;
  readonly supportsEventEmitters?: boolean;
  runTests(tests: Array<Test$1>, watcher: TestWatcher$1, onStart: OnTestStart, onResult: OnTestSuccess, onFailure: OnTestFailure, options: TestRunnerOptions): Promise<void>;
}
interface EmittingTestRunnerInterface {
  readonly isSerial?: boolean;
  readonly supportsEventEmitters: true;
  runTests(tests: Array<Test$1>, watcher: TestWatcher$1, options: TestRunnerOptions): Promise<void>;
  on<Name extends keyof TestEvents$1>(eventName: Name, listener: (eventData: TestEvents$1[Name]) => void | Promise<void>): UnsubscribeFn;
}
declare abstract class BaseTestRunner {
  protected readonly _globalConfig: Config$1.GlobalConfig;
  protected readonly _context: TestRunnerContext;
  readonly isSerial?: boolean;
  abstract readonly supportsEventEmitters: boolean;
  constructor(_globalConfig: Config$1.GlobalConfig, _context: TestRunnerContext);
}
declare abstract class CallbackTestRunner extends BaseTestRunner implements CallbackTestRunnerInterface {
  readonly supportsEventEmitters = false;
  abstract runTests(tests: Array<Test$1>, watcher: TestWatcher$1, onStart: OnTestStart, onResult: OnTestSuccess, onFailure: OnTestFailure, options: TestRunnerOptions): Promise<void>;
}
declare abstract class EmittingTestRunner extends BaseTestRunner implements EmittingTestRunnerInterface {
  readonly supportsEventEmitters = true;
  abstract runTests(tests: Array<Test$1>, watcher: TestWatcher$1, options: TestRunnerOptions): Promise<void>;
  abstract on<Name extends keyof TestEvents$1>(eventName: Name, listener: (eventData: TestEvents$1[Name]) => void | Promise<void>): UnsubscribeFn;
}
type JestTestRunner = CallbackTestRunner | EmittingTestRunner;
//#endregion
//#region src/index.d.ts
declare class TestRunner extends EmittingTestRunner {
  #private;
  runTests(tests: Array<Test$1>, watcher: TestWatcher$1, options: TestRunnerOptions): Promise<void>;
  on<Name extends keyof TestEvents$1>(eventName: Name, listener: (eventData: TestEvents$1[Name]) => void | Promise<void>): UnsubscribeFn;
}
//#endregion
export { CallbackTestRunner, CallbackTestRunnerInterface, Config, EmittingTestRunner, EmittingTestRunnerInterface, JestTestRunner, OnTestFailure, OnTestStart, OnTestSuccess, Test, TestEvents, TestRunnerContext, TestRunnerOptions, TestWatcher, UnsubscribeFn, TestRunner as default };