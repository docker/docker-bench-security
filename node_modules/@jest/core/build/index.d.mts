import { BaseReporter, Reporter, ReporterContext } from "@jest/reporters";
import { AggregatedResult, Test, TestContext } from "@jest/test-result";
import { TestWatcher } from "jest-watcher";
import { ChangedFiles } from "jest-changed-files";
import { TestPathPatternsExecutor } from "@jest/pattern";
import { Config } from "@jest/types";
import { TestRunnerContext } from "jest-runner";

//#region src/types.d.ts
type Stats = {
  roots: number;
  testMatch: number;
  testPathIgnorePatterns: number;
  testRegex: number;
  testPathPatterns?: number;
};
type Filter = (testPaths: Array<string>) => Promise<{
  filtered: Array<string>;
}>;
//#endregion
//#region src/SearchSource.d.ts
type SearchResult = {
  noSCM?: boolean;
  stats?: Stats;
  collectCoverageFrom?: Set<string>;
  tests: Array<Test>;
  total?: number;
};
declare class SearchSource {
  private readonly _context;
  private _dependencyResolver;
  private readonly _testPathCases;
  constructor(context: TestContext);
  private _getOrBuildDependencyResolver;
  private _filterTestPathsWithStats;
  private _getAllTestPaths;
  isTestFilePath(path: string): boolean;
  findMatchingTests(testPathPatternsExecutor: TestPathPatternsExecutor): SearchResult;
  findRelatedTests(allPaths: Set<string>, collectCoverage: boolean): Promise<SearchResult>;
  findTestsByPaths(paths: Array<string>): SearchResult;
  findRelatedTestsFromPattern(paths: Array<string>, collectCoverage: boolean): Promise<SearchResult>;
  findTestRelatedToChangedFiles(changedFilesInfo: ChangedFiles, collectCoverage: boolean): Promise<SearchResult>;
  private _getTestPaths;
  filterPathsWin32(paths: Array<string>): Array<string>;
  getTestPaths(globalConfig: Config.GlobalConfig, projectConfig: Config.ProjectConfig, changedFiles?: ChangedFiles, filter?: Filter): Promise<SearchResult>;
  findRelatedSourcesFromTestsInChangedFiles(changedFilesInfo: ChangedFiles): Promise<Array<string>>;
}
//#endregion
//#region src/TestScheduler.d.ts
type ReporterConstructor = new (globalConfig: Config.GlobalConfig, reporterConfig: Record<string, unknown>, reporterContext: ReporterContext) => BaseReporter;
type TestSchedulerContext = ReporterContext & TestRunnerContext;
declare function createTestScheduler(globalConfig: Config.GlobalConfig, context: TestSchedulerContext): Promise<TestScheduler>;
declare class TestScheduler {
  private readonly _context;
  private readonly _dispatcher;
  private readonly _globalConfig;
  constructor(globalConfig: Config.GlobalConfig, context: TestSchedulerContext);
  addReporter(reporter: Reporter): void;
  removeReporter(reporterConstructor: ReporterConstructor): void;
  scheduleTests(tests: Array<Test>, watcher: TestWatcher): Promise<AggregatedResult>;
  private _partitionTests;
  _setupReporters(): Promise<void>;
  private _addCustomReporter;
  private _bailIfNeeded;
}
//#endregion
//#region src/cli/index.d.ts
declare function runCLI(argv: Config.Argv, projects: Array<string>): Promise<{
  results: AggregatedResult;
  globalConfig: Config.GlobalConfig;
}>;
//#endregion
//#region src/version.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function getVersion(): string;
//#endregion
export { SearchSource, createTestScheduler, getVersion, runCLI };