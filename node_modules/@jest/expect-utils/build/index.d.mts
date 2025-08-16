//#region src/types.d.ts

type Tester = (this: TesterContext, a: any, b: any, customTesters: Array<Tester>) => boolean | undefined;
interface TesterContext {
  equals: EqualsFunction;
}
//#endregion
//#region src/jasmineUtils.d.ts
type EqualsFunction = (a: unknown, b: unknown, customTesters?: Array<Tester>, strictCheck?: boolean) => boolean;
declare const equals: EqualsFunction;
declare function isA<T>(typeName: string, value: unknown): value is T;
//#endregion
//#region src/utils.d.ts
type GetPath = {
  hasEndProp?: boolean;
  endPropIsDefined?: boolean;
  lastTraversedObject: unknown;
  traversedPath: Array<string>;
  value?: unknown;
};
declare const getObjectKeys: (object: object) => Array<string | symbol>;
declare const getPath: (object: Record<string, any>, propertyPath: string | Array<string>) => GetPath;
declare const getObjectSubset: (object: any, subset: any, customTesters?: Array<Tester>, seenReferences?: WeakMap<object, boolean>) => any;
declare const iterableEquality: (a: any, b: any, customTesters?: Array<Tester>, aStack?: Array<any>, bStack?: Array<any>) => boolean | undefined;
declare const subsetEquality: (object: unknown, subset: unknown, customTesters?: Array<Tester>) => boolean | undefined;
declare const typeEquality: (a: any, b: any) => boolean | undefined;
declare const arrayBufferEquality: (a: unknown, b: unknown) => boolean | undefined;
declare const sparseArrayEquality: (a: unknown, b: unknown, customTesters?: Array<Tester>) => boolean | undefined;
declare const partition: <T>(items: Array<T>, predicate: (arg: T) => boolean) => [Array<T>, Array<T>];
declare const pathAsArray: (propertyPath: string) => Array<any>;
declare const isError: (value: unknown) => value is Error;
declare function emptyObject(obj: unknown): boolean;
declare const isOneline: (expected: unknown, received: unknown) => boolean;
//#endregion
export { EqualsFunction, Tester, TesterContext, arrayBufferEquality, emptyObject, equals, getObjectKeys, getObjectSubset, getPath, isA, isError, isOneline, iterableEquality, partition, pathAsArray, sparseArrayEquality, subsetEquality, typeEquality };