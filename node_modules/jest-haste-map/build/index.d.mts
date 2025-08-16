import { Stats } from "fs";
import { Config } from "@jest/types";

//#region src/HasteFS.d.ts

declare class HasteFS implements IHasteFS {
  private readonly _rootDir;
  private readonly _files;
  constructor({
    rootDir,
    files
  }: {
    rootDir: string;
    files: FileData;
  });
  getModuleName(file: string): string | null;
  getSize(file: string): number | null;
  getDependencies(file: string): Array<string> | null;
  getSha1(file: string): string | null;
  exists(file: string): boolean;
  getAllFiles(): Array<string>;
  getFileIterator(): Iterable<string>;
  getAbsoluteFileIterator(): Iterable<string>;
  matchFiles(pattern: RegExp | string): Array<string>;
  matchFilesWithGlob(globs: Array<string>, root: string | null): Set<string>;
  private _getFileData;
}
//#endregion
//#region src/ModuleMap.d.ts
declare class ModuleMap$1 implements IModuleMap {
  static DuplicateHasteCandidatesError: typeof DuplicateHasteCandidatesError;
  private readonly _raw;
  private json;
  private static mapToArrayRecursive;
  private static mapFromArrayRecursive;
  constructor(raw: RawModuleMap);
  getModule(name: string, platform?: string | null, supportsNativePlatform?: boolean | null, type?: HTypeValue | null): string | null;
  getPackage(name: string, platform: string | null | undefined, _supportsNativePlatform: boolean | null): string | null;
  getMockModule(name: string): string | undefined;
  getRawModuleMap(): RawModuleMap;
  toJSON(): SerializableModuleMap;
  static fromJSON(serializableModuleMap: SerializableModuleMap): ModuleMap$1;
  /**
   * When looking up a module's data, we walk through each eligible platform for
   * the query. For each platform, we want to check if there are known
   * duplicates for that name+platform pair. The duplication logic normally
   * removes elements from the `map` object, but we want to check upfront to be
   * extra sure. If metadata exists both in the `duplicates` object and the
   * `map`, this would be a bug.
   */
  private _getModuleMetadata;
  private _assertNoDuplicates;
  static create(rootDir: string): ModuleMap$1;
}
declare class DuplicateHasteCandidatesError extends Error {
  hasteName: string;
  platform: string | null;
  supportsNativePlatform: boolean;
  duplicatesSet: DuplicatesSet;
  constructor(name: string, platform: string, supportsNativePlatform: boolean, duplicatesSet: DuplicatesSet);
}
//#endregion
//#region src/types.d.ts
type ValueType<T> = T extends Map<string, infer V> ? V : never;
type SerializableModuleMap = {
  duplicates: ReadonlyArray<[string, [string, [string, [string, number]]]]>;
  map: ReadonlyArray<[string, ValueType<ModuleMapData>]>;
  mocks: ReadonlyArray<[string, ValueType<MockData>]>;
  rootDir: string;
};
interface IModuleMap<S = SerializableModuleMap> {
  getModule(name: string, platform?: string | null, supportsNativePlatform?: boolean | null, type?: HTypeValue | null): string | null;
  getPackage(name: string, platform: string | null | undefined, _supportsNativePlatform: boolean | null): string | null;
  getMockModule(name: string): string | undefined;
  getRawModuleMap(): RawModuleMap;
  toJSON(): S;
}
interface IHasteFS {
  exists(path: string): boolean;
  getAbsoluteFileIterator(): Iterable<string>;
  getAllFiles(): Array<string>;
  getDependencies(file: string): Array<string> | null;
  getSize(path: string): number | null;
  matchFiles(pattern: RegExp | string): Array<string>;
  matchFilesWithGlob(globs: ReadonlyArray<string>, root: string | null): Set<string>;
  getModuleName(file: string): string | null;
}
interface IHasteMap {
  on(eventType: 'change', handler: (event: ChangeEvent) => void): void;
  build(): Promise<{
    hasteFS: IHasteFS;
    moduleMap: IModuleMap;
  }>;
}
type HasteMapStatic<S = SerializableModuleMap> = {
  getCacheFilePath(tmpdir: string, name: string, ...extra: Array<string>): string;
  getModuleMapFromJSON(json: S): IModuleMap<S>;
};
type FileData = Map<string, FileMetaData>;
type FileMetaData = [id: string, mtime: number, size: number, visited: 0 | 1, dependencies: string, sha1: string | null | undefined];
type MockData = Map<string, string>;
type ModuleMapData = Map<string, ModuleMapItem>;
type HasteRegExp = RegExp | ((str: string) => boolean);
type DuplicatesSet = Map<string, /* type */number>;
type DuplicatesIndex = Map<string, Map<string, DuplicatesSet>>;
type RawModuleMap = {
  rootDir: string;
  duplicates: DuplicatesIndex;
  map: ModuleMapData;
  mocks: MockData;
};
type ModuleMapItem = {
  [platform: string]: ModuleMetaData;
};
type ModuleMetaData = [path: string, type: number];
type HType = {
  ID: 0;
  MTIME: 1;
  SIZE: 2;
  VISITED: 3;
  DEPENDENCIES: 4;
  SHA1: 5;
  PATH: 0;
  TYPE: 1;
  MODULE: 0;
  PACKAGE: 1;
  GENERIC_PLATFORM: 'g';
  NATIVE_PLATFORM: 'native';
  DEPENDENCY_DELIM: '\0';
};
type HTypeValue = HType[keyof HType];
type EventsQueue = Array<{
  filePath: string;
  stat: Stats | undefined;
  type: string;
}>;
type ChangeEvent = {
  eventsQueue: EventsQueue;
  hasteFS: HasteFS;
  moduleMap: ModuleMap$1;
};
//#endregion
//#region src/index.d.ts
type Options = {
  cacheDirectory?: string;
  computeDependencies?: boolean;
  computeSha1?: boolean;
  console?: Console;
  dependencyExtractor?: string | null;
  enableSymlinks?: boolean;
  extensions: Array<string>;
  forceNodeFilesystemAPI?: boolean;
  hasteImplModulePath?: string;
  hasteMapModulePath?: string;
  id: string;
  ignorePattern?: HasteRegExp;
  maxWorkers: number;
  mocksPattern?: string;
  platforms: Array<string>;
  resetCache?: boolean;
  retainAllFiles: boolean;
  rootDir: string;
  roots: Array<string>;
  skipPackageJson?: boolean;
  throwOnModuleCollision?: boolean;
  useWatchman?: boolean;
  watch?: boolean;
  workerThreads?: boolean;
};
declare const ModuleMap: {
  create: (rootPath: string) => IModuleMap;
};
declare class DuplicateError extends Error {
  mockPath1: string;
  mockPath2: string;
  constructor(mockPath1: string, mockPath2: string);
}
type IJestHasteMap = HasteMapStatic & {
  create(options: Options): Promise<IHasteMap>;
  getStatic(config: Config.ProjectConfig): HasteMapStatic;
};
declare const JestHasteMap: IJestHasteMap;
//#endregion
export { DuplicateError, IHasteFS, IHasteMap, IModuleMap, ModuleMap, SerializableModuleMap, JestHasteMap as default };