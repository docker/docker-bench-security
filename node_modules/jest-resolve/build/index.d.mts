import { NapiResolveOptions } from "unrs-resolver";
import { IModuleMap } from "jest-haste-map";

//#region src/ModuleNotFoundError.d.ts

/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare class ModuleNotFoundError extends Error {
  code: string;
  hint?: string;
  requireStack?: Array<string>;
  siblingWithSimilarExtensionFound?: boolean;
  moduleName?: string;
  private _originalMessage?;
  constructor(message: string, moduleName?: string);
  buildMessage(rootDir: string): void;
  static duckType(error: ModuleNotFoundError): ModuleNotFoundError;
}
//#endregion
//#region src/defaultResolver.d.ts
interface ResolverOptions extends NapiResolveOptions {
  /** Directory to begin resolving from. */
  basedir: string;
  /** List of export conditions. */
  conditions?: Array<string>;
  /** Instance of default resolver. */
  defaultResolver: SyncResolver;
  /** Instance of default async resolver. */
  defaultAsyncResolver: AsyncResolver;
  /**
   * List of directory names to be looked up for modules recursively.
   *
   * @defaultValue
   * The default is `['node_modules']`.
   */
  moduleDirectory?: Array<string>;
  /**
   * List of `require.paths` to use if nothing is found in `node_modules`.
   *
   * @defaultValue
   * The default is `undefined`.
   */
  paths?: Array<string>;
  /** Current root directory. */
  rootDir?: string;
}
type SyncResolver = (path: string, options: ResolverOptions) => string;
type AsyncResolver = (path: string, options: ResolverOptions) => Promise<string>;
//#endregion
//#region src/shouldLoadAsEsm.d.ts
declare function cachedShouldLoadAsEsm(path: string, extensionsToTreatAsEsm: Array<string>): boolean;
//#endregion
//#region src/types.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
type ResolverConfig = {
  defaultPlatform?: string | null;
  extensions: Array<string>;
  hasCoreModules: boolean;
  moduleDirectories: Array<string>;
  moduleNameMapper?: Array<ModuleNameMapperConfig> | null;
  modulePaths?: Array<string>;
  platforms?: Array<string>;
  resolver?: string | null;
  rootDir: string;
};
type ModuleNameMapperConfig = {
  regex: RegExp;
  moduleName: string | Array<string>;
};
type JSONValue = string | number | boolean | JSONObject | Array<JSONValue>;
interface JSONObject {
  [key: string]: JSONValue;
}
type PackageJSON = JSONObject;
//#endregion
//#region src/resolver.d.ts
type FindNodeModuleConfig = {
  basedir: string;
  conditions?: Array<string>;
  extensions?: Array<string>;
  moduleDirectory?: Array<string>;
  paths?: Array<string>;
  resolver?: string | null;
  rootDir?: string;
  throwIfNotFound?: boolean;
};
type ResolveModuleConfig = {
  conditions?: Array<string>;
  skipNodeResolution?: boolean;
  paths?: Array<string>;
};
declare class Resolver {
  private readonly _options;
  private readonly _moduleMap;
  private readonly _moduleIDCache;
  private readonly _moduleNameCache;
  private readonly _modulePathCache;
  private readonly _supportsNativePlatform;
  constructor(moduleMap: IModuleMap, options: ResolverConfig);
  static ModuleNotFoundError: typeof ModuleNotFoundError;
  static tryCastModuleNotFoundError(error: unknown): ModuleNotFoundError | null;
  static clearDefaultResolverCache(): void;
  static findNodeModule(path: string, options: FindNodeModuleConfig): string | null;
  static findNodeModuleAsync(path: string, options: FindNodeModuleConfig): Promise<string | null>;
  static unstable_shouldLoadAsEsm: typeof cachedShouldLoadAsEsm;
  resolveModuleFromDirIfExists(dirname: string, moduleName: string, options?: ResolveModuleConfig): string | null;
  resolveModuleFromDirIfExistsAsync(dirname: string, moduleName: string, options?: ResolveModuleConfig): Promise<string | null>;
  resolveModule(from: string, moduleName: string, options?: ResolveModuleConfig): string;
  resolveModuleAsync(from: string, moduleName: string, options?: ResolveModuleConfig): Promise<string>;
  /**
   * _prepareForResolution is shared between the sync and async module resolution
   * methods, to try to keep them as DRY as possible.
   */
  private _prepareForResolution;
  /**
   * _getHasteModulePath attempts to return the path to a haste module.
   */
  private _getHasteModulePath;
  private _throwModNotFoundError;
  private _getMapModuleName;
  private _isAliasModule;
  isCoreModule(moduleName: string): boolean;
  normalizeCoreModuleSpecifier(specifier: string): string;
  getModule(name: string): string | null;
  getModulePath(from: string, moduleName: string): string;
  getPackage(name: string): string | null;
  getMockModule(from: string, name: string, options?: Pick<ResolveModuleConfig, 'conditions'>): string | null;
  getMockModuleAsync(from: string, name: string, options: Pick<ResolveModuleConfig, 'conditions'>): Promise<string | null>;
  getModulePaths(from: string): Array<string>;
  getGlobalPaths(moduleName?: string): Array<string>;
  getModuleID(virtualMocks: Map<string, boolean>, from: string, moduleName: string | undefined, options: ResolveModuleConfig): string;
  getModuleIDAsync(virtualMocks: Map<string, boolean>, from: string, moduleName: string | undefined, options: ResolveModuleConfig): Promise<string>;
  private _getModuleType;
  private _getAbsolutePath;
  private _getAbsolutePathAsync;
  private _getMockPath;
  private _getMockPathAsync;
  private _getVirtualMockPath;
  private _getVirtualMockPathAsync;
  private _isModuleResolved;
  private _isModuleResolvedAsync;
  resolveStubModuleName(from: string, moduleName: string, options?: Pick<ResolveModuleConfig, 'conditions'>): string | null;
  resolveStubModuleNameAsync(from: string, moduleName: string, options?: Pick<ResolveModuleConfig, 'conditions'>): Promise<string | null>;
}
type ResolverSyncObject = {
  sync: SyncResolver;
  async?: AsyncResolver;
};
type ResolverAsyncObject = {
  sync?: SyncResolver;
  async: AsyncResolver;
};
type ResolverObject = ResolverSyncObject | ResolverAsyncObject;
//#endregion
//#region src/utils.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
/**
 * Finds the test environment to use:
 *
 * 1. looks for jest-environment-<name> relative to project.
 * 1. looks for jest-environment-<name> relative to Jest.
 * 1. looks for <name> relative to project.
 * 1. looks for <name> relative to Jest.
 */
declare const resolveTestEnvironment: ({
  rootDir,
  testEnvironment: filePath,
  requireResolveFunction
}: {
  rootDir: string;
  testEnvironment: string;
  requireResolveFunction: (moduleName: string) => string;
}) => string;
/**
 * Finds the watch plugins to use:
 *
 * 1. looks for jest-watch-<name> relative to project.
 * 1. looks for jest-watch-<name> relative to Jest.
 * 1. looks for <name> relative to project.
 * 1. looks for <name> relative to Jest.
 */
declare const resolveWatchPlugin: (resolver: string | undefined | null, {
  filePath,
  rootDir,
  requireResolveFunction
}: {
  filePath: string;
  rootDir: string;
  requireResolveFunction: (moduleName: string) => string;
}) => string;
/**
 * Finds the runner to use:
 *
 * 1. looks for jest-runner-<name> relative to project.
 * 1. looks for jest-runner-<name> relative to Jest.
 * 1. looks for <name> relative to project.
 * 1. looks for <name> relative to Jest.
 */
declare const resolveRunner: (resolver: string | undefined | null, {
  filePath,
  rootDir,
  requireResolveFunction
}: {
  filePath: string;
  rootDir: string;
  requireResolveFunction: (moduleName: string) => string;
}) => string;
declare const resolveSequencer: (resolver: string | undefined | null, {
  filePath,
  rootDir,
  requireResolveFunction
}: {
  filePath: string;
  rootDir: string;
  requireResolveFunction: (moduleName: string) => string;
}) => string;
//#endregion
export { AsyncResolver, FindNodeModuleConfig, ResolverObject as JestResolver, PackageJSON, ResolveModuleConfig, ResolverOptions, SyncResolver, Resolver as default, resolveRunner, resolveSequencer, resolveTestEnvironment, resolveWatchPlugin };