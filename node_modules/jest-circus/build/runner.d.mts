import { JestEnvironment } from "@jest/environment";
import { TestFileEvent, TestResult } from "@jest/test-result";
import { Config } from "@jest/types";
import Runtime from "jest-runtime";

//#region src/legacy-code-todo-rewrite/jestAdapter.d.ts

declare const jestAdapter: (globalConfig: Config.GlobalConfig, config: Config.ProjectConfig, environment: JestEnvironment, runtime: Runtime, testPath: string, sendMessageToJest?: TestFileEvent) => Promise<TestResult>;
//#endregion
export { jestAdapter as default };