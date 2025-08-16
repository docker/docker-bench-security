import { __export } from "./chunk-BQ42LXoh.mjs";
import { DeprecatedOptions } from "jest-validate";
import { Config } from "@jest/types";

//#region src/constants.d.ts
declare namespace constants_d_exports {
  export { DEFAULT_JS_PATTERN, JEST_CONFIG_BASE_NAME, JEST_CONFIG_EXT_CJS, JEST_CONFIG_EXT_CTS, JEST_CONFIG_EXT_JS, JEST_CONFIG_EXT_JSON, JEST_CONFIG_EXT_MJS, JEST_CONFIG_EXT_ORDER, JEST_CONFIG_EXT_TS, NODE_MODULES, PACKAGE_JSON };
}
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare const NODE_MODULES: string;
declare const DEFAULT_JS_PATTERN = "\\.[jt]sx?$";
declare const PACKAGE_JSON = "package.json";
declare const JEST_CONFIG_BASE_NAME = "jest.config";
declare const JEST_CONFIG_EXT_CJS = ".cjs";
declare const JEST_CONFIG_EXT_MJS = ".mjs";
declare const JEST_CONFIG_EXT_JS = ".js";
declare const JEST_CONFIG_EXT_TS = ".ts";
declare const JEST_CONFIG_EXT_CTS = ".cts";
declare const JEST_CONFIG_EXT_JSON = ".json";
declare const JEST_CONFIG_EXT_ORDER: readonly string[];
//#endregion
//#region src/utils.d.ts
declare const replaceRootDirInPath: (rootDir: string, filePath: string) => string;
type JSONString = string & {
  readonly $$type: never;
};
declare const isJSONString: (text?: JSONString | string) => text is JSONString;
//#endregion
//#region src/normalize.d.ts
type AllOptions = Config.ProjectConfig & Config.GlobalConfig;
declare function normalize(initialOptions: Config.InitialOptions, argv: Config.Argv, configPath?: string | null, projectIndex?: number, isProjectOptions?: boolean): Promise<{
  hasDeprecationWarnings: boolean;
  options: AllOptions;
}>;
//#endregion
//#region src/Deprecated.d.ts
declare const deprecatedOptions: DeprecatedOptions;
//#endregion
//#region src/Defaults.d.ts
declare const defaultOptions: Config.DefaultOptions;
//#endregion
//#region src/Descriptions.d.ts
declare const descriptions: { [key in keyof Config.InitialOptions]: string };
//#endregion
//#region src/index.d.ts
type ReadConfig = {
  configPath: string | null | undefined;
  globalConfig: Config.GlobalConfig;
  hasDeprecationWarnings: boolean;
  projectConfig: Config.ProjectConfig;
};
declare function readConfig(argv: Config.Argv, packageRootOrConfig: string | Config.InitialOptions, skipArgvConfigOption?: boolean, parentConfigDirname?: string | null, projectIndex?: number, skipMultipleConfigError?: boolean): Promise<ReadConfig>;
interface ReadJestConfigOptions {
  /**
   * The package root or deserialized config (default is cwd)
   */
  packageRootOrConfig?: string | Config.InitialOptions;
  /**
   * When the `packageRootOrConfig` contains config, this parameter should
   * contain the dirname of the parent config
   */
  parentConfigDirname?: null | string;
  /**
   * Indicates whether or not to read the specified config file from disk.
   * When true, jest will read try to read config from the current working directory.
   * (default is false)
   */
  readFromCwd?: boolean;
  /**
   * Indicates whether or not to ignore the error of jest finding multiple config files.
   * (default is false)
   */
  skipMultipleConfigError?: boolean;
}
/**
 * Reads the jest config, without validating them or filling it out with defaults.
 * @param config The path to the file or serialized config.
 * @param param1 Additional options
 * @returns The raw initial config (not validated)
 */
declare function readInitialOptions(config?: string, {
  packageRootOrConfig,
  parentConfigDirname,
  readFromCwd,
  skipMultipleConfigError
}?: ReadJestConfigOptions): Promise<{
  config: Config.InitialOptions;
  configPath: string | null;
}>;
declare function readConfigs(argv: Config.Argv, projectPaths: Array<string>): Promise<{
  globalConfig: Config.GlobalConfig;
  configs: Array<Config.ProjectConfig>;
  hasDeprecationWarnings: boolean;
}>;
//#endregion
export { ReadJestConfigOptions, constants_d_exports as constants, defaultOptions as defaults, deprecatedOptions as deprecationEntries, descriptions, isJSONString, normalize, readConfig, readConfigs, readInitialOptions, replaceRootDirInPath };