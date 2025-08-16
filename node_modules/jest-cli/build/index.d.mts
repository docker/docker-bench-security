import { Options } from "yargs";
import { Config } from "@jest/types";

//#region src/run.d.ts

declare function run(maybeArgv?: Array<string>, project?: string): Promise<void>;
declare function buildArgv(maybeArgv?: Array<string>): Promise<Config.Argv>;
//#endregion
//#region src/args.d.ts
declare const options: {
  [key: string]: Options;
};
//#endregion
export { buildArgv, run, options as yargsOptions };