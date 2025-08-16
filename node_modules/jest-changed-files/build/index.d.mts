//#region src/types.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
type Options = {
  lastCommit?: boolean;
  withAncestor?: boolean;
  changedSince?: string;
  includePaths?: Array<string>;
};
type Paths = Set<string>;
type Repos = {
  git: Paths;
  hg: Paths;
  sl: Paths;
};
type ChangedFiles = {
  repos: Repos;
  changedFiles: Paths;
};
type ChangedFilesPromise = Promise<ChangedFiles>;
//#endregion
//#region src/index.d.ts
declare const getChangedFilesForRoots: (roots: Array<string>, options: Options) => ChangedFilesPromise;
declare const findRepos: (roots: Array<string>) => Promise<Repos>;
//#endregion
export { ChangedFiles, ChangedFilesPromise, findRepos, getChangedFilesForRoots };