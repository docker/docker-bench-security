import { __export } from "./chunk-BQ42LXoh.mjs";
import { WriteStream } from "tty";
import { Config, Global } from "@jest/types";

//#region src/preRunMessage.d.ts
declare namespace preRunMessage_d_exports {
  export { print, remove };
}
declare function print(stream: WriteStream): void;
declare function remove(stream: WriteStream): void;
declare namespace specialChars_d_exports {
  export { ARROW, CLEAR, ICONS };
}
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare const ARROW = " \u203A ";
declare const ICONS: {
  failed: string;
  pending: string;
  success: string;
  todo: string;
};
declare const CLEAR: string;
//#endregion
//#region src/clearLine.d.ts
declare function clearLine(stream: WriteStream): void;
//#endregion
//#region src/createDirectory.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function createDirectory(path: string): void;
//#endregion
//#region src/ErrorWithStack.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare class ErrorWithStack extends Error {
  constructor(message: string | undefined, callsite: (...args: Array<any>) => unknown, stackLimit?: number);
}
//#endregion
//#region src/garbage-collection-utils.d.ts
/**
 *  - <b>off</b>: deletion is completely turned off.
 *  - <b>soft</b>: doesn't delete objects, but instead wraps their getter/setter with a deprecation warning.
 *  - <b>on</b>: actually delete objects (using `delete`).
 */
type DeletionMode = 'soft' | 'off' | 'on';
/**
 * Initializes the garbage collection utils with the given deletion mode.
 *
 * @param globalObject the global object on which to store the deletion mode.
 * @param deletionMode the deletion mode to use.
 */
declare function initializeGarbageCollectionUtils(globalObject: typeof globalThis, deletionMode: DeletionMode): void;
/**
 * Deletes all the properties from the given value (if it's an object),
 * unless the value was protected via {@link #protectProperties}.
 *
 * @param value the given value.
 */
declare function deleteProperties(value: unknown): void;
/**
 * Protects the given value from being deleted by {@link #deleteProperties}.
 *
 * @param value The given value.
 * @param properties If the array contains any property,
 * then only these properties will be protected; otherwise if the array is empty,
 * all properties will be protected.
 * @param depth Determines how "deep" the protection should be.
 * A value of 0 means that only the top-most properties will be protected,
 * while a value larger than 0 means that deeper levels of nesting will be protected as well.
 */
declare function protectProperties<T>(value: T, properties?: Array<keyof T>, depth?: number): boolean;
/**
 * Whether the given value has properties that can be deleted (regardless of protection).
 *
 * @param value The given value.
 */
declare function canDeleteProperties(value: unknown): value is object;
//#endregion
//#region src/installCommonGlobals.d.ts
declare function installCommonGlobals(globalObject: typeof globalThis, globals: Config.ConfigGlobals, garbageCollectionDeletionMode?: DeletionMode): typeof globalThis & Config.ConfigGlobals;
//#endregion
//#region src/interopRequireDefault.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function interopRequireDefault(obj: any): any;
//#endregion
//#region src/isInteractive.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare const isInteractive: boolean;
//#endregion
//#region src/isPromise.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function isPromise<T = unknown>(candidate: unknown): candidate is PromiseLike<T>;
//#endregion
//#region src/setGlobal.d.ts
declare function setGlobal(globalToMutate: typeof globalThis | Global.Global, key: string | symbol, value: unknown, afterTeardown?: 'clean' | 'retain'): void;
//#endregion
//#region src/deepCyclicCopy.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
type DeepCyclicCopyOptions = {
  blacklist?: Set<string>;
  keepPrototype?: boolean;
};
declare function deepCyclicCopy<T>(value: T, options?: DeepCyclicCopyOptions, cycles?: WeakMap<any, any>): T;
//#endregion
//#region src/convertDescriptorToString.d.ts
declare function convertDescriptorToString(descriptor: Global.BlockNameLike | undefined): string;
//#endregion
//#region src/replacePathSepForGlob.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function replacePathSepForGlob(path: string): string;
//#endregion
//#region src/globsToMatcher.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
type Matcher = (str: string) => boolean;
/**
 * Converts a list of globs into a function that matches a path against the
 * globs.
 *
 * Every time picomatch is called, it will parse the glob strings and turn
 * them into regexp instances. Instead of calling picomatch repeatedly with
 * the same globs, we can use this function which will build the picomatch
 * matchers ahead of time and then have an optimized path for determining
 * whether an individual path matches.
 *
 * This function is intended to match the behavior of `micromatch()`.
 *
 * @example
 * const isMatch = globsToMatcher(['*.js', '!*.test.js']);
 * isMatch('pizza.js'); // true
 * isMatch('pizza.test.js'); // false
 */
declare function globsToMatcher(globs: Array<string>): Matcher;
//#endregion
//#region src/pluralize.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function pluralize(word: string, count: number, ending?: string): string;
//#endregion
//#region src/formatTime.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function formatTime(time: number, prefixPower?: number, padLeftLength?: number): string;
//#endregion
//#region src/tryRealpath.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function tryRealpath(path: string): string;
//#endregion
//#region src/requireOrImportModule.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function requireOrImportModule<T>(filePath: string, applyInteropRequireDefault?: boolean): Promise<T>;
//#endregion
//#region src/invariant.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function invariant(condition: unknown, message?: string): asserts condition;
//#endregion
//#region src/isNonNullable.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function isNonNullable<T>(value: T): value is NonNullable<T>;
//#endregion
export { DeletionMode, ErrorWithStack, canDeleteProperties, clearLine, convertDescriptorToString, createDirectory, deepCyclicCopy, deleteProperties, formatTime, globsToMatcher, initializeGarbageCollectionUtils, installCommonGlobals, interopRequireDefault, invariant, isInteractive, isNonNullable, isPromise, pluralize, preRunMessage_d_exports as preRunMessage, protectProperties, replacePathSepForGlob, requireOrImportModule, setGlobal, specialChars_d_exports as specialChars, tryRealpath };