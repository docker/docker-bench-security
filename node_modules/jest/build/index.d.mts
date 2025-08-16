import { SearchSource, createTestScheduler, getVersion, runCLI } from "@jest/core";
import { buildArgv, run } from "jest-cli";
import { Config as Config$1 } from "@jest/types";

//#region src/index.d.ts

type Config = Config$1.InitialOptions;
//#endregion
export { Config, SearchSource, buildArgv, createTestScheduler, getVersion, run, runCLI };