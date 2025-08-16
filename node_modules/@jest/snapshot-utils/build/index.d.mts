import { Config } from "@jest/types";

//#region src/types.d.ts

/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
type SnapshotData = Record<string, string>;
//#endregion
//#region src/utils.d.ts

declare const SNAPSHOT_VERSION = "1";
declare const SNAPSHOT_GUIDE_LINK = "https://jestjs.io/docs/snapshot-testing";
declare const SNAPSHOT_VERSION_WARNING: string;
declare const testNameToKey: (testName: string, count: number) => string;
declare const keyToTestName: (key: string) => string;
declare const getSnapshotData: (snapshotPath: string, update: Config.SnapshotUpdateState) => {
  data: SnapshotData;
  dirty: boolean;
};
declare const escapeBacktickString: (str: string) => string;
declare const ensureDirectoryExists: (filePath: string) => void;
declare const normalizeNewlines: (string: string) => string;
declare const saveSnapshotFile: (snapshotData: SnapshotData, snapshotPath: string) => void;
//#endregion
export { SNAPSHOT_GUIDE_LINK, SNAPSHOT_VERSION, SNAPSHOT_VERSION_WARNING, SnapshotData, ensureDirectoryExists, escapeBacktickString, getSnapshotData, keyToTestName, normalizeNewlines, saveSnapshotFile, testNameToKey };