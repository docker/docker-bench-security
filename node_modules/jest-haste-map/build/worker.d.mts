//#region src/types.d.ts

type WorkerMessage = {
  computeDependencies: boolean;
  computeSha1: boolean;
  dependencyExtractor?: string | null;
  rootDir: string;
  filePath: string;
  hasteImplModulePath?: string;
  retainAllFiles?: boolean;
};
type WorkerMetadata = {
  dependencies: Array<string> | undefined | null;
  id: string | undefined | null;
  module: ModuleMetaData | undefined | null;
  sha1: string | undefined | null;
};
type ModuleMetaData = [path: string, type: number];
//#endregion
//#region src/worker.d.ts
declare function worker(data: WorkerMessage): Promise<WorkerMetadata>;
declare function getSha1(data: WorkerMessage): Promise<WorkerMetadata>;
//#endregion
export { getSha1, worker };