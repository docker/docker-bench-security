import { Options } from "yargs";
import { Config } from "@jest/types";

//#region src/utils.d.ts

declare const format: (value: unknown) => string;
declare class ValidationError extends Error {
  name: string;
  message: string;
  constructor(name: string, message: string, comment?: string | null);
}
declare const logValidationWarning: (name: string, message: string, comment?: string | null) => void;
declare const createDidYouMeanMessage: (unrecognized: string, allowedOptions: Array<string>) => string;
//#endregion
//#region src/types.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
type Title = {
  deprecation?: string;
  error?: string;
  warning?: string;
};
type DeprecatedOptionFunc = (arg: Record<string, unknown>) => string;
type DeprecatedOptions = Record<string, DeprecatedOptionFunc>;
type ValidationOptions = {
  comment?: string;
  condition?: (option: unknown, validOption: unknown) => boolean;
  deprecate?: (config: Record<string, unknown>, option: string, deprecatedOptions: DeprecatedOptions, options: ValidationOptions) => boolean;
  deprecatedConfig?: DeprecatedOptions;
  error?: (option: string, received: unknown, defaultValue: unknown, options: ValidationOptions, path?: Array<string>) => void;
  exampleConfig: Record<string, unknown>;
  recursive?: boolean;
  recursiveDenylist?: Array<string>;
  title?: Title;
  unknown?: (config: Record<string, unknown>, exampleConfig: Record<string, unknown>, option: string, options: ValidationOptions, path?: Array<string>) => void;
};
//#endregion
//#region src/validate.d.ts
declare const validate: (config: Record<string, unknown>, options: ValidationOptions) => {
  hasDeprecationWarnings: boolean;
  isValid: boolean;
};
//#endregion
//#region src/validateCLIOptions.d.ts
declare function validateCLIOptions(argv: Config.Argv, options?: Record<string, Options> & {
  deprecationEntries?: DeprecatedOptions;
}, rawArgv?: Array<string>): boolean;
//#endregion
//#region src/condition.d.ts
declare function multipleValidOptions<T extends Array<unknown>>(...args: T): T[number];
//#endregion
export { DeprecatedOptions, ValidationError, createDidYouMeanMessage, format, logValidationWarning, multipleValidOptions, validate, validateCLIOptions };