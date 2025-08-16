import { Global } from "@jest/types";

//#region src/bind.d.ts

type GlobalCallback = (testName: string, fn: Global.ConcurrentTestFn, timeout?: number, eachError?: Error) => void;
declare function bind<EachCallback extends Global.TestCallback>(cb: GlobalCallback, supportsDone?: boolean, needsEachError?: boolean): Global.EachTestFn<any>;
//#endregion
//#region src/index.d.ts
type Global$1 = Global$1.Global;
declare const install: (g: Global$1, table: Global$1.EachTable, ...data: Global$1.TemplateData) => {
  describe: {
    (title: string, suite: Global$1.EachTestFn<Global$1.BlockFn>, timeout?: number): any;
    skip: any;
    only: any;
  };
  fdescribe: any;
  fit: any;
  it: {
    (title: string, test: Global$1.EachTestFn<Global$1.TestFn>, timeout?: number): any;
    skip: any;
    only: any;
    concurrent: {
      (title: string, test: Global$1.EachTestFn<Global$1.TestFn>, timeout?: number): any;
      only: any;
      skip: any;
    };
  };
  test: {
    (title: string, test: Global$1.EachTestFn<Global$1.TestFn>, timeout?: number): any;
    skip: any;
    only: any;
    concurrent: {
      (title: string, test: Global$1.EachTestFn<Global$1.TestFn>, timeout?: number): any;
      only: any;
      skip: any;
    };
  };
  xdescribe: any;
  xit: any;
  xtest: any;
};
declare const each: {
  (table: Global$1.EachTable, ...data: Global$1.TemplateData): ReturnType<typeof install>;
  withGlobal(g: Global$1): (table: Global$1.EachTable, ...data: Global$1.TemplateData) => {
    describe: {
      (title: string, suite: Global$1.EachTestFn<Global$1.BlockFn>, timeout?: number): any;
      skip: any;
      only: any;
    };
    fdescribe: any;
    fit: any;
    it: {
      (title: string, test: Global$1.EachTestFn<Global$1.TestFn>, timeout?: number): any;
      skip: any;
      only: any;
      concurrent: {
        (title: string, test: Global$1.EachTestFn<Global$1.TestFn>, timeout?: number): any;
        only: any;
        skip: any;
      };
    };
    test: {
      (title: string, test: Global$1.EachTestFn<Global$1.TestFn>, timeout?: number): any;
      skip: any;
      only: any;
      concurrent: {
        (title: string, test: Global$1.EachTestFn<Global$1.TestFn>, timeout?: number): any;
        only: any;
        skip: any;
      };
    };
    xdescribe: any;
    xit: any;
    xtest: any;
  };
};
//#endregion
export { bind, each as default };