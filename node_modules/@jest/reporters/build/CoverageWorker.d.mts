import { FileCoverage } from "istanbul-lib-coverage";
import { Config } from "@jest/types";
import { V8Coverage } from "collect-v8-coverage";

//#region src/generateEmptyCoverage.d.ts

type SingleV8Coverage = V8Coverage[number];
type CoverageWorkerResult = {
  kind: 'BabelCoverage';
  coverage: FileCoverage;
} | {
  kind: 'V8Coverage';
  result: SingleV8Coverage;
};
//#endregion
//#region src/types.d.ts

type ReporterContext = {
  firstRun: boolean;
  previousSuccess: boolean;
  changedFiles?: Set<string>;
  sourcesRelatedToTestsInChangedFiles?: Set<string>;
  startRun?: (globalConfig: Config.GlobalConfig) => unknown;
};
//#endregion
//#region src/CoverageWorker.d.ts
type SerializeSet<T> = T extends Set<infer U> ? Array<U> : T;
type CoverageReporterContext = Pick<ReporterContext, 'changedFiles' | 'sourcesRelatedToTestsInChangedFiles'>;
type CoverageReporterSerializedContext = { [K in keyof CoverageReporterContext]: SerializeSet<ReporterContext[K]> };
type CoverageWorkerData = {
  config: Config.ProjectConfig;
  context: CoverageReporterSerializedContext;
  globalConfig: Config.GlobalConfig;
  path: string;
};
declare function worker({
  config,
  globalConfig,
  path,
  context
}: CoverageWorkerData): Promise<CoverageWorkerResult | null>;
//#endregion
export { CoverageWorkerData, worker };