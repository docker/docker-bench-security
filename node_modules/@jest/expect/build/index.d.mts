import { AsymmetricMatchers, AsymmetricMatchers as AsymmetricMatchers$1, BaseExpect, MatcherContext, MatcherFunction, MatcherFunctionWithContext, MatcherState, MatcherUtils, Matchers, Matchers as Matchers$1 } from "expect";
import { SnapshotMatchers, SnapshotState, addSerializer } from "jest-snapshot";

//#region src/types.d.ts

type JestExpect = {
  <T = unknown>(actual: T): JestMatchers<void, T> & Inverse<JestMatchers<void, T>> & PromiseMatchers<T>;
  addSnapshotSerializer: typeof addSerializer;
} & BaseExpect & AsymmetricMatchers$1 & Inverse<Omit<AsymmetricMatchers$1, 'any' | 'anything'>>;
type Inverse<Matchers> = {
  /**
   * Inverse next matcher. If you know how to test something, `.not` lets you test its opposite.
   */
  not: Matchers$1;
};
type JestMatchers<R extends void | Promise<void>, T> = Matchers$1<R, T> & SnapshotMatchers<R, T>;
type PromiseMatchers<T = unknown> = {
  /**
   * Unwraps the reason of a rejected promise so any other matcher can be chained.
   * If the promise is fulfilled the assertion fails.
   */
  rejects: JestMatchers<Promise<void>, T> & Inverse<JestMatchers<Promise<void>, T>>;
  /**
   * Unwraps the value of a fulfilled promise so any other matcher can be chained.
   * If the promise is rejected the assertion fails.
   */
  resolves: JestMatchers<Promise<void>, T> & Inverse<JestMatchers<Promise<void>, T>>;
};
declare module 'expect' {
  interface MatcherState {
    snapshotState: SnapshotState;
    /** Whether the test was called with `test.failing()` */
    testFailing?: boolean;
  }
  interface BaseExpect {
    addSnapshotSerializer: typeof addSerializer;
  }
}
//#endregion
//#region src/index.d.ts
declare const jestExpect: JestExpect;
//#endregion
export { AsymmetricMatchers, JestExpect, MatcherContext, MatcherFunction, MatcherFunctionWithContext, MatcherState, MatcherUtils, Matchers, jestExpect };