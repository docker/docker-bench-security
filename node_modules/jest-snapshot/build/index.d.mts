import { Plugin, Plugins, PrettyFormatOptions } from "pretty-format";
import "jest-message-util";
import { Config } from "@jest/types";
import { MatcherContext, MatcherFunctionWithContext } from "expect";

//#region src/SnapshotResolver.d.ts

type SnapshotResolver = {
  /** Resolves from `testPath` to snapshot path. */
  resolveSnapshotPath(testPath: string, snapshotExtension?: string): string;
  /** Resolves from `snapshotPath` to test path. */
  resolveTestPath(snapshotPath: string, snapshotExtension?: string): string;
  /** Example test path, used for preflight consistency check of the implementation above. */
  testPathForConsistencyCheck: string;
};
declare const EXTENSION = "snap";
declare const isSnapshotPath: (path: string) => boolean;
type LocalRequire = (module: string) => unknown;
declare const buildSnapshotResolver: (config: Config.ProjectConfig, localRequire?: Promise<LocalRequire> | LocalRequire) => Promise<SnapshotResolver>;
//#endregion
//#region src/State.d.ts
type SnapshotStateOptions = {
  readonly updateSnapshot: Config.SnapshotUpdateState;
  readonly prettierPath?: string | null;
  readonly expand?: boolean;
  readonly snapshotFormat: SnapshotFormat;
  readonly rootDir: string;
};
type SnapshotMatchOptions = {
  readonly testName: string;
  readonly received: unknown;
  readonly key?: string;
  readonly inlineSnapshot?: string;
  readonly isInline: boolean;
  readonly error?: Error;
  readonly testFailing?: boolean;
};
type SnapshotReturnOptions = {
  readonly actual: string;
  readonly count: number;
  readonly expected?: string;
  readonly key: string;
  readonly pass: boolean;
};
type SaveStatus = {
  deleted: boolean;
  saved: boolean;
};
declare class SnapshotState {
  private _counters;
  private _dirty;
  private _index;
  private readonly _updateSnapshot;
  private _snapshotData;
  private readonly _initialData;
  private readonly _snapshotPath;
  private _inlineSnapshots;
  private readonly _uncheckedKeys;
  private readonly _prettierPath;
  private readonly _rootDir;
  readonly snapshotFormat: SnapshotFormat;
  added: number;
  expand: boolean;
  matched: number;
  unmatched: number;
  updated: number;
  constructor(snapshotPath: string, options: SnapshotStateOptions);
  markSnapshotsAsCheckedForTest(testName: string): void;
  private _addSnapshot;
  clear(): void;
  save(): SaveStatus;
  getUncheckedCount(): number;
  getUncheckedKeys(): Array<string>;
  removeUncheckedKeys(): void;
  match({
    testName,
    received,
    key,
    inlineSnapshot,
    isInline,
    error,
    testFailing
  }: SnapshotMatchOptions): SnapshotReturnOptions;
  fail(testName: string, _received: unknown, key?: string): string;
}
//#endregion
//#region src/types.d.ts
interface Context extends MatcherContext {
  snapshotState: SnapshotState;
  testFailing?: boolean;
}
interface FileSystem {
  exists(path: string): boolean;
  matchFiles(pattern: RegExp | string): Array<string>;
}
interface SnapshotMatchers<R extends void | Promise<void>, T> {
  /**
   * This ensures that a value matches the most recent snapshot with property matchers.
   * Check out [the Snapshot Testing guide](https://jestjs.io/docs/snapshot-testing) for more information.
   */
  toMatchSnapshot(hint?: string): R;
  /**
   * This ensures that a value matches the most recent snapshot.
   * Check out [the Snapshot Testing guide](https://jestjs.io/docs/snapshot-testing) for more information.
   */
  toMatchSnapshot<U extends Record<keyof T, unknown>>(propertyMatchers: Partial<U>, hint?: string): R;
  /**
   * This ensures that a value matches the most recent snapshot with property matchers.
   * Instead of writing the snapshot value to a .snap file, it will be written into the source code automatically.
   * Check out [the Snapshot Testing guide](https://jestjs.io/docs/snapshot-testing) for more information.
   */
  toMatchInlineSnapshot(snapshot?: string): R;
  /**
   * This ensures that a value matches the most recent snapshot with property matchers.
   * Instead of writing the snapshot value to a .snap file, it will be written into the source code automatically.
   * Check out [the Snapshot Testing guide](https://jestjs.io/docs/snapshot-testing) for more information.
   */
  toMatchInlineSnapshot<U extends Record<keyof T, unknown>>(propertyMatchers: Partial<U>, snapshot?: string): R;
  /**
   * Used to test that a function throws a error matching the most recent snapshot when it is called.
   */
  toThrowErrorMatchingSnapshot(hint?: string): R;
  /**
   * Used to test that a function throws a error matching the most recent snapshot when it is called.
   * Instead of writing the snapshot value to a .snap file, it will be written into the source code automatically.
   */
  toThrowErrorMatchingInlineSnapshot(snapshot?: string): R;
}
type SnapshotFormat = Omit<PrettyFormatOptions, 'compareKeys'>;
//#endregion
//#region src/plugins.d.ts
declare const addSerializer: (plugin: Plugin) => void;
declare const getSerializers: () => Plugins;
//#endregion
//#region src/index.d.ts
declare const cleanup: (fileSystem: FileSystem, update: Config.SnapshotUpdateState, snapshotResolver: SnapshotResolver, testPathIgnorePatterns?: Config.ProjectConfig["testPathIgnorePatterns"]) => {
  filesRemoved: number;
  filesRemovedList: Array<string>;
};
declare const toMatchSnapshot: MatcherFunctionWithContext<Context, [propertiesOrHint?: object | string, hint?: string]>;
declare const toMatchInlineSnapshot: MatcherFunctionWithContext<Context, [propertiesOrSnapshot?: object | string, inlineSnapshot?: string]>;
declare const toThrowErrorMatchingSnapshot: MatcherFunctionWithContext<Context, [hint?: string, fromPromise?: boolean]>;
declare const toThrowErrorMatchingInlineSnapshot: MatcherFunctionWithContext<Context, [inlineSnapshot?: string, fromPromise?: boolean]>;
//#endregion
export { Context, EXTENSION, SnapshotMatchers, SnapshotResolver, SnapshotState, addSerializer, buildSnapshotResolver, cleanup, getSerializers, isSnapshotPath, toMatchInlineSnapshot, toMatchSnapshot, toThrowErrorMatchingInlineSnapshot, toThrowErrorMatchingSnapshot };