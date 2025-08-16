import { SerializableModuleMap } from "jest-haste-map";
import Runtime from "jest-runtime";
import { TestResult } from "@jest/test-result";
import { Config } from "@jest/types";

//#region src/types.d.ts

type TestRunnerContext = {
  changedFiles?: Set<string>;
  sourcesRelatedToTestsInChangedFiles?: Set<string>;
};
type SerializeSet<T> = T extends Set<infer U> ? Array<U> : T;
type TestRunnerSerializedContext = { [K in keyof TestRunnerContext]: SerializeSet<TestRunnerContext[K]> };
//#endregion
//#region src/testWorker.d.ts
type SerializableResolver = {
  config: Config.ProjectConfig;
  serializableModuleMap: SerializableModuleMap;
};
type WorkerData = {
  config: Config.ProjectConfig;
  globalConfig: Config.GlobalConfig;
  path: string;
  context: TestRunnerSerializedContext;
};
declare function setup(setupData: {
  serializableResolvers: Array<SerializableResolver>;
}): void;
declare function worker({
  config,
  globalConfig,
  path,
  context
}: WorkerData): Promise<TestResult>;
//#endregion
export { SerializableResolver, setup, worker };