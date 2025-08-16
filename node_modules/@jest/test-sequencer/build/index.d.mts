import { AggregatedResult, Test, TestContext } from "@jest/test-result";
import { Config } from "@jest/types";

//#region src/index.d.ts

declare const FAIL = 0;
declare const SUCCESS = 1;
type TestSequencerOptions = {
  contexts: ReadonlyArray<TestContext>;
  globalConfig: Config.GlobalConfig;
};
type Cache = {
  [key: string]: [testStatus: typeof FAIL | typeof SUCCESS, testDuration: number] | undefined;
};
type ShardOptions = {
  shardIndex: number;
  shardCount: number;
};
/**
 * The TestSequencer will ultimately decide which tests should run first.
 * It is responsible for storing and reading from a local cache
 * map that stores context information for a given test, such as how long it
 * took to run during the last run and if it has failed or not.
 * Such information is used on:
 * TestSequencer.sort(tests: Array<Test>)
 * to sort the order of the provided tests.
 *
 * After the results are collected,
 * TestSequencer.cacheResults(tests: Array<Test>, results: AggregatedResult)
 * is called to store/update this information on the cache map.
 */
declare class TestSequencer {
  private readonly _cache;
  constructor(_options: TestSequencerOptions);
  _getCachePath(testContext: TestContext): string;
  _getCache(test: Test): Cache;
  private _shardPosition;
  /**
   * Select tests for shard requested via --shard=shardIndex/shardCount
   * Sharding is applied before sorting
   *
   * @param tests All tests
   * @param options shardIndex and shardIndex to select
   *
   * @example
   * ```typescript
   * class CustomSequencer extends Sequencer {
   *  shard(tests, { shardIndex, shardCount }) {
   *    const shardSize = Math.ceil(tests.length / options.shardCount);
   *    const shardStart = shardSize * (options.shardIndex - 1);
   *    const shardEnd = shardSize * options.shardIndex;
   *    return [...tests]
   *     .sort((a, b) => (a.path > b.path ? 1 : -1))
   *     .slice(shardStart, shardEnd);
   *  }
   * }
   * ```
   */
  shard(tests: Array<Test>, options: ShardOptions): Array<Test> | Promise<Array<Test>>;
  /**
   * Sort test to determine order of execution
   * Sorting is applied after sharding
   * @param tests
   *
   * ```typescript
   * class CustomSequencer extends Sequencer {
   *   sort(tests) {
   *     const copyTests = Array.from(tests);
   *     return [...tests].sort((a, b) => (a.path > b.path ? 1 : -1));
   *   }
   * }
   * ```
   */
  sort(tests: Array<Test>): Array<Test> | Promise<Array<Test>>;
  allFailedTests(tests: Array<Test>): Array<Test> | Promise<Array<Test>>;
  cacheResults(tests: Array<Test>, results: AggregatedResult): void;
  private hasFailed;
  private time;
}
//#endregion
export { ShardOptions, TestSequencerOptions, TestSequencer as default };