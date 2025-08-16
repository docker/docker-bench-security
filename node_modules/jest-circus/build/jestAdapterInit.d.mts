import { JestExpect } from "@jest/expect";
import { TestFileEvent, TestResult } from "@jest/test-result";
import { SnapshotState } from "jest-snapshot";
import * as Process from "process";
import { JestEnvironment } from "@jest/environment";
import { Circus, Config, Global } from "@jest/types";
import Runtime from "jest-runtime";

//#region src/legacy-code-todo-rewrite/jestAdapterInit.d.ts

interface RuntimeGlobals extends Global.TestFrameworkGlobals {
  expect: JestExpect;
}
declare const initialize: ({
  config,
  environment,
  runtime,
  globalConfig,
  localRequire,
  parentProcess,
  sendMessageToJest,
  setGlobalsForRuntime,
  testPath
}: {
  config: Config.ProjectConfig;
  environment: JestEnvironment;
  runtime: Runtime;
  globalConfig: Config.GlobalConfig;
  localRequire: <T = unknown>(path: string) => T;
  testPath: string;
  parentProcess: typeof Process;
  sendMessageToJest?: TestFileEvent;
  setGlobalsForRuntime: (globals: RuntimeGlobals) => void;
}) => Promise<{
  globals: Global.TestFrameworkGlobals;
  snapshotState: SnapshotState;
}>;
declare const runAndTransformResultsToJestFormat: ({
  config,
  globalConfig,
  setupAfterEnvPerfStats,
  testPath
}: {
  config: Config.ProjectConfig;
  globalConfig: Config.GlobalConfig;
  testPath: string;
  setupAfterEnvPerfStats: Config.SetupAfterEnvPerfStats;
}) => Promise<TestResult>;
declare const eventHandler: (event: Circus.Event) => Promise<void>;
//#endregion
export { eventHandler, initialize, runAndTransformResultsToJestFormat };