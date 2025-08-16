import Emittery from "emittery";
import { ReadStream, WriteStream } from "tty";
import { Config } from "@jest/types";
import { AggregatedResult } from "@jest/test-result";

//#region src/types.d.ts

type TestSuiteInfo = {
  config: Config.ProjectConfig;
  duration?: number;
  testPath: string;
};
type JestHookExposedFS = {
  projects: Array<{
    config: Config.ProjectConfig;
    testPaths: Array<string>;
  }>;
};
type FileChange = (fs: JestHookExposedFS) => void;
type ShouldRunTestSuite = (testSuiteInfo: TestSuiteInfo) => Promise<boolean>;
type TestRunComplete = (results: AggregatedResult) => void;
type JestHookSubscriber = {
  onFileChange: (fn: FileChange) => void;
  onTestRunComplete: (fn: TestRunComplete) => void;
  shouldRunTestSuite: (fn: ShouldRunTestSuite) => void;
};
type JestHookEmitter = {
  onFileChange: (fs: JestHookExposedFS) => void;
  onTestRunComplete: (results: AggregatedResult) => void;
  shouldRunTestSuite: (testSuiteInfo: TestSuiteInfo) => Promise<boolean> | boolean;
};
type UsageData = {
  key: string;
  prompt: string;
};
type AllowedConfigOptions = Partial<Pick<Config.GlobalConfig, 'bail' | 'changedSince' | 'collectCoverage' | 'collectCoverageFrom' | 'coverageDirectory' | 'coverageReporters' | 'findRelatedTests' | 'nonFlagArgs' | 'notify' | 'notifyMode' | 'onlyFailures' | 'reporters' | 'testNamePattern' | 'updateSnapshot' | 'verbose'> & {
  mode: 'watch' | 'watchAll';
  testPathPatterns: Array<string>;
}>;
type UpdateConfigCallback = (config?: AllowedConfigOptions) => void;
interface WatchPlugin {
  isInternal?: boolean;
  apply?: (hooks: JestHookSubscriber) => void;
  getUsageInfo?: (globalConfig: Config.GlobalConfig) => UsageData | null;
  onKey?: (value: string) => void;
  run?: (globalConfig: Config.GlobalConfig, updateConfigAndRun: UpdateConfigCallback) => Promise<void | boolean>;
}
type WatchPluginClass = new (options: {
  config: Record<string, unknown>;
  stdin: ReadStream;
  stdout: WriteStream;
}) => WatchPlugin;
type ScrollOptions = {
  offset: number;
  max: number;
};
//#endregion
//#region src/BaseWatchPlugin.d.ts
declare abstract class BaseWatchPlugin implements WatchPlugin {
  protected _stdin: ReadStream;
  protected _stdout: WriteStream;
  constructor({
    stdin,
    stdout
  }: {
    stdin: ReadStream;
    stdout: WriteStream;
  });
  apply(_hooks: JestHookSubscriber): void;
  getUsageInfo(_globalConfig: Config.GlobalConfig): UsageData | null;
  onKey(_key: string): void;
  run(_globalConfig: Config.GlobalConfig, _updateConfigAndRun: UpdateConfigCallback): Promise<void | boolean>;
}
//#endregion
//#region src/JestHooks.d.ts
type AvailableHooks = 'onFileChange' | 'onTestRunComplete' | 'shouldRunTestSuite';
declare class JestHooks {
  private readonly _listeners;
  private readonly _subscriber;
  private readonly _emitter;
  constructor();
  isUsed(hook: AvailableHooks): boolean;
  getSubscriber(): Readonly<JestHookSubscriber>;
  getEmitter(): Readonly<JestHookEmitter>;
}
//#endregion
//#region src/lib/Prompt.d.ts
declare class Prompt {
  private _entering;
  private _value;
  private _onChange;
  private _onSuccess;
  private _onCancel;
  private _offset;
  private _promptLength;
  private _selection;
  constructor();
  private readonly _onResize;
  enter(onChange: (pattern: string, options: ScrollOptions) => void, onSuccess: (pattern: string) => void, onCancel: () => void): void;
  setPromptLength(length: number): void;
  setPromptSelection(selected: string): void;
  put(key: string): void;
  abort(): void;
  isEntering(): boolean;
}
//#endregion
//#region src/PatternPrompt.d.ts
declare abstract class PatternPrompt {
  protected _pipe: NodeJS.WritableStream;
  protected _prompt: Prompt;
  protected _entityName: string;
  protected _currentUsageRows: number;
  constructor(_pipe: NodeJS.WritableStream, _prompt: Prompt, _entityName?: string);
  run(onSuccess: (value: string) => void, onCancel: () => void, options?: {
    header: string;
  }): void;
  protected _onChange(_pattern: string, _options: ScrollOptions): void;
}
//#endregion
//#region src/TestWatcher.d.ts
type State = {
  interrupted: boolean;
};
declare class TestWatcher extends Emittery<{
  change: State;
}> {
  state: State;
  private readonly _isWatchMode;
  constructor({
    isWatchMode
  }: {
    isWatchMode: boolean;
  });
  setState(state: State): Promise<void>;
  isInterrupted(): boolean;
  isWatchMode(): boolean;
}
//#endregion
//#region src/constants.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare const KEYS: {
  ARROW_DOWN: string;
  ARROW_LEFT: string;
  ARROW_RIGHT: string;
  ARROW_UP: string;
  BACKSPACE: string;
  CONTROL_C: string;
  CONTROL_D: string;
  CONTROL_U: string;
  ENTER: string;
  ESCAPE: string;
};
//#endregion
//#region src/lib/patternModeHelpers.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function printPatternCaret(pattern: string, pipe: NodeJS.WritableStream): void;
declare function printRestoredPatternCaret(pattern: string, currentUsageRows: number, pipe: NodeJS.WritableStream): void;
//#endregion
export { AllowedConfigOptions, BaseWatchPlugin, JestHooks as JestHook, JestHookEmitter, JestHookSubscriber, KEYS, PatternPrompt, Prompt, ScrollOptions, TestWatcher, UpdateConfigCallback, UsageData, WatchPlugin, WatchPluginClass, printPatternCaret, printRestoredPatternCaret };