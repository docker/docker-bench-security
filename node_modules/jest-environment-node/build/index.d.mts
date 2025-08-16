import { Context } from "vm";
import { LegacyFakeTimers, ModernFakeTimers } from "@jest/fake-timers";
import { ModuleMocker } from "jest-mock";
import { EnvironmentContext, JestEnvironment, JestEnvironmentConfig } from "@jest/environment";
import { Global } from "@jest/types";

//#region src/index.d.ts

type Timer = {
  id: number;
  ref: () => Timer;
  unref: () => Timer;
};
declare class NodeEnvironment implements JestEnvironment<Timer> {
  context: Context | null;
  fakeTimers: LegacyFakeTimers<Timer> | null;
  fakeTimersModern: ModernFakeTimers | null;
  global: Global.Global;
  moduleMocker: ModuleMocker | null;
  customExportConditions: string[];
  private readonly _configuredExportConditions?;
  private _globalProxy;
  constructor(config: JestEnvironmentConfig, _context: EnvironmentContext);
  setup(): Promise<void>;
  teardown(): Promise<void>;
  exportConditions(): Array<string>;
  getVmContext(): Context | null;
}
declare const TestEnvironment: typeof NodeEnvironment;
//#endregion
export { TestEnvironment, NodeEnvironment as default };