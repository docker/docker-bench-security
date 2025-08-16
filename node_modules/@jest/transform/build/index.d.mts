import { Config, TransformTypes } from "@jest/types";
import { EncodedSourceMap } from "@jridgewell/trace-mapping";

//#region src/types.d.ts

interface ShouldInstrumentOptions extends Pick<Config.GlobalConfig, 'collectCoverage' | 'collectCoverageFrom' | 'coverageProvider'> {
  changedFiles?: Set<string>;
  sourcesRelatedToTestsInChangedFiles?: Set<string>;
}
interface Options extends ShouldInstrumentOptions, CallerTransformOptions {
  isInternalModule?: boolean;
}
interface FixedRawSourceMap extends Omit<EncodedSourceMap, 'version'> {
  version: number;
}
type TransformedSource = {
  code: string;
  map?: FixedRawSourceMap | string | null;
};
type TransformResult = TransformTypes.TransformResult;
interface CallerTransformOptions {
  supportsDynamicImport: boolean;
  supportsExportNamespaceFrom: boolean;
  supportsStaticESM: boolean;
  supportsTopLevelAwait: boolean;
}
interface ReducedTransformOptions extends CallerTransformOptions {
  instrument: boolean;
}
interface RequireAndTranspileModuleOptions extends ReducedTransformOptions {
  applyInteropRequireDefault: boolean;
}
type StringMap = Map<string, string>;
interface TransformOptions<TransformerConfig = unknown> extends ReducedTransformOptions {
  /** Cached file system which is used by `jest-runtime` to improve performance. */
  cacheFS: StringMap;
  /** Jest configuration of currently running project. */
  config: Config.ProjectConfig;
  /** Stringified version of the `config` - useful in cache busting. */
  configString: string;
  /** Transformer configuration passed through `transform` option by the user. */
  transformerConfig: TransformerConfig;
}
interface SyncTransformer<TransformerConfig = unknown> {
  /**
   * Indicates if the transformer is capable of instrumenting the code for code coverage.
   *
   * If V8 coverage is _not_ active, and this is `true`, Jest will assume the code is instrumented.
   * If V8 coverage is _not_ active, and this is `false`. Jest will instrument the code returned by this transformer using Babel.
   */
  canInstrument?: boolean;
  getCacheKey?: (sourceText: string, sourcePath: string, options: TransformOptions<TransformerConfig>) => string;
  getCacheKeyAsync?: (sourceText: string, sourcePath: string, options: TransformOptions<TransformerConfig>) => Promise<string>;
  process: (sourceText: string, sourcePath: string, options: TransformOptions<TransformerConfig>) => TransformedSource;
  processAsync?: (sourceText: string, sourcePath: string, options: TransformOptions<TransformerConfig>) => Promise<TransformedSource>;
}
interface AsyncTransformer<TransformerConfig = unknown> {
  /**
   * Indicates if the transformer is capable of instrumenting the code for code coverage.
   *
   * If V8 coverage is _not_ active, and this is `true`, Jest will assume the code is instrumented.
   * If V8 coverage is _not_ active, and this is `false`. Jest will instrument the code returned by this transformer using Babel.
   */
  canInstrument?: boolean;
  getCacheKey?: (sourceText: string, sourcePath: string, options: TransformOptions<TransformerConfig>) => string;
  getCacheKeyAsync?: (sourceText: string, sourcePath: string, options: TransformOptions<TransformerConfig>) => Promise<string>;
  process?: (sourceText: string, sourcePath: string, options: TransformOptions<TransformerConfig>) => TransformedSource;
  processAsync: (sourceText: string, sourcePath: string, options: TransformOptions<TransformerConfig>) => Promise<TransformedSource>;
}
/**
 * We have both sync (`process`) and async (`processAsync`) code transformation, which both can be provided.
 * `require` will always use `process`, and `import` will use `processAsync` if it exists, otherwise fall back to `process`.
 * Meaning, if you use `import` exclusively you do not need `process`, but in most cases supplying both makes sense:
 * Jest transpiles on demand rather than ahead of time, so the sync one needs to exist.
 *
 * For more info on the sync vs async model, see https://jestjs.io/docs/code-transformation#writing-custom-transformers
 */
type Transformer<TransformerConfig = unknown> = SyncTransformer<TransformerConfig> | AsyncTransformer<TransformerConfig>;
type TransformerCreator<X extends Transformer<TransformerConfig>, TransformerConfig = unknown> = (transformerConfig?: TransformerConfig) => X | Promise<X>;
/**
 * Instead of having your custom transformer implement the Transformer interface
 * directly, you can choose to export a factory function to dynamically create
 * transformers. This is to allow having a transformer config in your jest config.
 */
type TransformerFactory<X extends Transformer> = {
  createTransformer: TransformerCreator<X>;
};
//#endregion
//#region src/ScriptTransformer.d.ts
declare class ScriptTransformer {
  private readonly _config;
  private readonly _cacheFS;
  private readonly _cache;
  private readonly _transformCache;
  private _transformsAreLoaded;
  constructor(_config: Config.ProjectConfig, _cacheFS: StringMap);
  private _buildCacheKeyFromFileInfo;
  private _buildTransformCacheKey;
  private _getCacheKey;
  private _getCacheKeyAsync;
  private _createCachedFilename;
  private _getFileCachePath;
  private _getFileCachePathAsync;
  private _getTransformPatternAndPath;
  private _getTransformPath;
  loadTransformers(): Promise<void>;
  private _getTransformer;
  private _instrumentFile;
  private _buildTransformResult;
  transformSource(filepath: string, content: string, options: ReducedTransformOptions): TransformResult;
  transformSourceAsync(filepath: string, content: string, options: ReducedTransformOptions): Promise<TransformResult>;
  private _transformAndBuildScriptAsync;
  private _transformAndBuildScript;
  transformAsync(filename: string, options: Options, fileSource?: string): Promise<TransformResult>;
  transform(filename: string, options: Options, fileSource?: string): TransformResult;
  transformJson(filename: string, options: Options, fileSource: string): string;
  requireAndTranspileModule<ModuleType = unknown>(moduleName: string, callback?: (module: ModuleType) => void | Promise<void>, options?: RequireAndTranspileModuleOptions): Promise<ModuleType>;
  shouldTransform(filename: string): boolean;
}
declare function createTranspilingRequire(config: Config.ProjectConfig): Promise<(<TModuleType = unknown>(resolverPath: string, applyInteropRequireDefault?: boolean) => Promise<TModuleType>)>;
type TransformerType = ScriptTransformer;
declare function createScriptTransformer(config: Config.ProjectConfig, cacheFS?: StringMap): Promise<TransformerType>;
//#endregion
//#region src/shouldInstrument.d.ts
declare function shouldInstrument(filename: string, options: ShouldInstrumentOptions, config: Config.ProjectConfig, loadedFilenames?: Array<string>): boolean;
//#endregion
//#region src/enhanceUnexpectedTokenMessage.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
interface ErrorWithCodeFrame extends Error {
  codeFrame?: string;
}
declare function handlePotentialSyntaxError(e: ErrorWithCodeFrame): ErrorWithCodeFrame;
//#endregion
export { AsyncTransformer, CallerTransformOptions, TransformerType as ScriptTransformer, ShouldInstrumentOptions, SyncTransformer, TransformOptions, TransformResult, Options as TransformationOptions, TransformedSource, Transformer, TransformerCreator, TransformerFactory, createScriptTransformer, createTranspilingRequire, handlePotentialSyntaxError, shouldInstrument };