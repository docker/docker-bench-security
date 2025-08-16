//#region src/index.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
/// <reference lib="ESNext.Disposable" preserve="true" />
type MockMetadataType = 'object' | 'array' | 'regexp' | 'function' | 'constant' | 'collection' | 'null' | 'undefined';
type MockMetadata<T, MetadataType = MockMetadataType> = {
  ref?: number;
  members?: Record<string, MockMetadata<T>>;
  mockImpl?: T;
  name?: string;
  refID?: number;
  type?: MetadataType;
  value?: T;
  length?: number;
};
type ClassLike = new (...args: any) => any;
type FunctionLike = (...args: any) => any;
type ConstructorLikeKeys<T> = keyof { [K in keyof T as Required<T>[K] extends ClassLike ? K : never]: T[K] };
type MethodLikeKeys<T> = keyof { [K in keyof T as Required<T>[K] extends FunctionLike ? K : never]: T[K] };
type PropertyLikeKeys<T> = Exclude<keyof T, ConstructorLikeKeys<T> | MethodLikeKeys<T>>;
type MockedClass<T extends ClassLike> = MockInstance<(...args: ConstructorParameters<T>) => Mocked<InstanceType<T>>> & MockedObject<T>;
type MockedFunction<T extends FunctionLike> = MockInstance<T> & MockedObject<T>;
type MockedFunctionShallow<T extends FunctionLike> = MockInstance<T> & T;
type MockedObject<T extends object> = { [K in keyof T]: T[K] extends ClassLike ? MockedClass<T[K]> : T[K] extends FunctionLike ? MockedFunction<T[K]> : T[K] extends object ? MockedObject<T[K]> : T[K] } & T;
type MockedObjectShallow<T extends object> = { [K in keyof T]: T[K] extends ClassLike ? MockedClass<T[K]> : T[K] extends FunctionLike ? MockedFunctionShallow<T[K]> : T[K] } & T;
type Mocked<T> = T extends ClassLike ? MockedClass<T> : T extends FunctionLike ? MockedFunction<T> : T extends object ? MockedObject<T> : T;
type MockedShallow<T> = T extends ClassLike ? MockedClass<T> : T extends FunctionLike ? MockedFunctionShallow<T> : T extends object ? MockedObjectShallow<T> : T;
type UnknownFunction = (...args: Array<unknown>) => unknown;
type UnknownClass = new (...args: Array<unknown>) => unknown;
type SpiedClass<T extends ClassLike = UnknownClass> = MockInstance<(...args: ConstructorParameters<T>) => InstanceType<T>>;
type SpiedFunction<T extends FunctionLike = UnknownFunction> = MockInstance<(...args: Parameters<T>) => ReturnType<T>>;
type SpiedGetter<T> = MockInstance<() => T>;
type SpiedSetter<T> = MockInstance<(arg: T) => void>;
type Spied<T extends ClassLike | FunctionLike> = T extends ClassLike ? SpiedClass<T> : T extends FunctionLike ? SpiedFunction<T> : never;
/**
 * All what the internal typings need is to be sure that we have any-function.
 * `FunctionLike` type ensures that and helps to constrain the type as well.
 * The default of `UnknownFunction` makes sure that `any`s do not leak to the
 * user side. For instance, calling `fn()` without implementation will return
 * a mock of `(...args: Array<unknown>) => unknown` type. If implementation
 * is provided, its typings are inferred correctly.
 */
interface Mock<T extends FunctionLike = UnknownFunction> extends Function, MockInstance<T> {
  new (...args: Parameters<T>): ReturnType<T>;
  (...args: Parameters<T>): ReturnType<T>;
}
type ResolveType<T extends FunctionLike> = ReturnType<T> extends PromiseLike<infer U> ? U : never;
type RejectType<T extends FunctionLike> = ReturnType<T> extends PromiseLike<any> ? unknown : never;
interface MockInstance<T extends FunctionLike = UnknownFunction> extends Disposable {
  _isMockFunction: true;
  _protoImpl: Function;
  getMockImplementation(): T | undefined;
  getMockName(): string;
  mock: MockFunctionState<T>;
  mockClear(): this;
  mockReset(): this;
  mockRestore(): void;
  mockImplementation(fn: T): this;
  mockImplementationOnce(fn: T): this;
  withImplementation(fn: T, callback: () => Promise<unknown>): Promise<void>;
  withImplementation(fn: T, callback: () => void): void;
  mockName(name: string): this;
  mockReturnThis(): this;
  mockReturnValue(value: ReturnType<T>): this;
  mockReturnValueOnce(value: ReturnType<T>): this;
  mockResolvedValue(value: ResolveType<T>): this;
  mockResolvedValueOnce(value: ResolveType<T>): this;
  mockRejectedValue(value: RejectType<T>): this;
  mockRejectedValueOnce(value: RejectType<T>): this;
}
interface Replaced<T = unknown> {
  /**
   * Restore property to its original value known at the time of mocking.
   */
  restore(): void;
  /**
   * Change the value of the property.
   */
  replaceValue(value: T): this;
}
type MockFunctionResultIncomplete = {
  type: 'incomplete';
  /**
   * Result of a single call to a mock function that has not yet completed.
   * This occurs if you test the result from within the mock function itself,
   * or from within a function that was called by the mock.
   */
  value: undefined;
};
type MockFunctionResultReturn<T extends FunctionLike = UnknownFunction> = {
  type: 'return';
  /**
   * Result of a single call to a mock function that returned.
   */
  value: ReturnType<T>;
};
type MockFunctionResultThrow = {
  type: 'throw';
  /**
   * Result of a single call to a mock function that threw.
   */
  value: unknown;
};
type MockFunctionResult<T extends FunctionLike = UnknownFunction> = MockFunctionResultIncomplete | MockFunctionResultReturn<T> | MockFunctionResultThrow;
type MockFunctionState<T extends FunctionLike = UnknownFunction> = {
  /**
   * List of the call arguments of all calls that have been made to the mock.
   */
  calls: Array<Parameters<T>>;
  /**
   * List of all the object instances that have been instantiated from the mock.
   */
  instances: Array<ReturnType<T>>;
  /**
   * List of all the function contexts that have been applied to calls to the mock.
   */
  contexts: Array<ThisParameterType<T>>;
  /**
   * List of the call order indexes of the mock. Jest is indexing the order of
   * invocations of all mocks in a test file. The index is starting with `1`.
   */
  invocationCallOrder: Array<number>;
  /**
   * List of the call arguments of the last call that was made to the mock.
   * If the function was not called, it will return `undefined`.
   */
  lastCall?: Parameters<T>;
  /**
   * List of the results of all calls that have been made to the mock.
   */
  results: Array<MockFunctionResult<T>>;
};
declare class ModuleMocker {
  private readonly _environmentGlobal;
  private _mockState;
  private _mockConfigRegistry;
  private _spyState;
  private _invocationCallCounter;
  /**
   * @see README.md
   * @param global Global object of the test environment, used to create
   * mocks
   */
  constructor(global: typeof globalThis);
  private _getSlots;
  private _ensureMockConfig;
  private _ensureMockState;
  private _defaultMockConfig;
  private _defaultMockState;
  private _makeComponent;
  private _createMockFunction;
  private _generateMock;
  /**
   * Check whether the given property of an object has been already replaced.
   */
  private _findReplacedProperty;
  /**
   * @see README.md
   * @param metadata Metadata for the mock in the schema returned by the
   * getMetadata method of this module.
   */
  generateFromMetadata<T>(metadata: MockMetadata<T>): Mocked<T>;
  /**
   * @see README.md
   * @param component The component for which to retrieve metadata.
   */
  getMetadata<T = unknown>(component: T, _refs?: Map<T, number>): MockMetadata<T> | null;
  isMockFunction<T extends FunctionLike = UnknownFunction>(fn: MockInstance<T>): fn is MockInstance<T>;
  isMockFunction<P extends Array<unknown>, R>(fn: (...args: P) => R): fn is Mock<(...args: P) => R>;
  isMockFunction(fn: unknown): fn is Mock<UnknownFunction>;
  fn<T extends FunctionLike = UnknownFunction>(implementation?: T): Mock<T>;
  spyOn<T extends object, K extends PropertyLikeKeys<T>, V extends Required<T>[K], A extends 'get' | 'set'>(object: T, methodKey: K, accessType: A): A extends 'get' ? SpiedGetter<V> : A extends 'set' ? SpiedSetter<V> : never;
  spyOn<T extends object, K extends ConstructorLikeKeys<T> | MethodLikeKeys<T>, V extends Required<T>[K]>(object: T, methodKey: K): V extends ClassLike | FunctionLike ? Spied<V> : never;
  private _spyOnProperty;
  replaceProperty<T extends object, K extends keyof T>(object: T, propertyKey: K, value: T[K]): Replaced<T[K]>;
  clearAllMocks(): void;
  resetAllMocks(): void;
  restoreAllMocks(): void;
  private _typeOf;
  mocked<T extends object>(source: T, options?: {
    shallow: false;
  }): Mocked<T>;
  mocked<T extends object>(source: T, options: {
    shallow: true;
  }): MockedShallow<T>;
}
declare const fn: <T extends FunctionLike = UnknownFunction>(implementation?: T) => Mock<T>;
declare const spyOn: {
  <T extends object, K extends PropertyLikeKeys<T>, V extends Required<T>[K], A extends "get" | "set">(object: T, methodKey: K, accessType: A): A extends "get" ? SpiedGetter<V> : A extends "set" ? SpiedSetter<V> : never;
  <T extends object, K extends ConstructorLikeKeys<T> | MethodLikeKeys<T>, V extends Required<T>[K]>(object: T, methodKey: K): V extends ClassLike | FunctionLike ? Spied<V> : never;
};
declare const mocked: {
  <T extends object>(source: T, options?: {
    shallow: false;
  }): Mocked<T>;
  <T extends object>(source: T, options: {
    shallow: true;
  }): MockedShallow<T>;
};
declare const replaceProperty: <T extends object, K extends keyof T>(object: T, propertyKey: K, value: T[K]) => Replaced<T[K]>;
//#endregion
export { ClassLike, ConstructorLikeKeys, FunctionLike, MethodLikeKeys, Mock, MockInstance, MockMetadata, MockMetadataType, Mocked, MockedClass, MockedFunction, MockedObject, MockedShallow, ModuleMocker, PropertyLikeKeys, Replaced, Spied, SpiedClass, SpiedFunction, SpiedGetter, SpiedSetter, UnknownClass, UnknownFunction, fn, mocked, replaceProperty, spyOn };