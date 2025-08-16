import { ResourceLimits } from "worker_threads";
import { ForkOptions } from "child_process";

//#region src/types.d.ts

type ReservedKeys = 'end' | 'getStderr' | 'getStdout' | 'setup' | 'teardown';
type ExcludeReservedKeys<K> = Exclude<K, ReservedKeys>;
type FunctionLike = (...args: any) => unknown;
type MethodLikeKeys<T> = { [K in keyof T]: T[K] extends FunctionLike ? K : never }[keyof T];
type Promisify<T extends FunctionLike> = ReturnType<T> extends Promise<infer R> ? (...args: Parameters<T>) => Promise<R> : (...args: Parameters<T>) => Promise<ReturnType<T>>;
type WorkerModule<T> = { [K in keyof T as Extract<ExcludeReservedKeys<K>, MethodLikeKeys<T>>]: T[K] extends FunctionLike ? Promisify<T[K]> : never };
declare const CHILD_MESSAGE_INITIALIZE = 0;
declare const CHILD_MESSAGE_CALL = 1;
declare const CHILD_MESSAGE_END = 2;
declare const CHILD_MESSAGE_MEM_USAGE = 3;
declare const CHILD_MESSAGE_CALL_SETUP = 4;
type WorkerCallback = (workerId: number, request: ChildMessage, onStart: OnStart, onEnd: OnEnd, onCustomMessage: OnCustomMessage) => void;
interface WorkerPoolInterface {
  getStderr(): NodeJS.ReadableStream;
  getStdout(): NodeJS.ReadableStream;
  getWorkers(): Array<WorkerInterface>;
  createWorker(options: WorkerOptions): WorkerInterface;
  send: WorkerCallback;
  start(): Promise<void>;
  end(): Promise<PoolExitResult>;
}
interface WorkerInterface {
  get state(): WorkerStates;
  send(request: ChildMessage, onProcessStart: OnStart, onProcessEnd: OnEnd, onCustomMessage: OnCustomMessage): void;
  waitForExit(): Promise<void>;
  forceExit(): void;
  getWorkerId(): number;
  getStderr(): NodeJS.ReadableStream | null;
  getStdout(): NodeJS.ReadableStream | null;
  /**
   * Some system level identifier for the worker. IE, process id, thread id, etc.
   */
  getWorkerSystemId(): number;
  getMemoryUsage(): Promise<number | null>;
  /**
   * Checks to see if the child worker is actually running.
   */
  isWorkerRunning(): boolean;
  /**
   * When the worker child is started and ready to start handling requests.
   *
   * @remarks
   * This mostly exists to help with testing so that you don't check the status
   * of things like isWorkerRunning before it actually is.
   */
  waitForWorkerReady(): Promise<void>;
}
type PoolExitResult = {
  forceExited: boolean;
};
interface PromiseWithCustomMessage<T> extends Promise<T> {
  UNSTABLE_onCustomMessage?: (listener: OnCustomMessage) => () => void;
}
interface TaskQueue {
  /**
   * Enqueues the task in the queue for the specified worker or adds it to the
   * queue shared by all workers
   * @param task the task to queue
   * @param workerId the id of the worker that should process this task or undefined
   * if there's no preference.
   */
  enqueue(task: QueueChildMessage, workerId?: number): void;
  /**
   * Dequeues the next item from the queue for the specified worker
   * @param workerId the id of the worker for which the next task should be retrieved
   */
  dequeue(workerId: number): QueueChildMessage | null;
}
type WorkerSchedulingPolicy = 'round-robin' | 'in-order';
type WorkerFarmOptions = {
  computeWorkerKey?: (method: string, ...args: Array<unknown>) => string | null;
  enableWorkerThreads?: boolean;
  exposedMethods?: ReadonlyArray<string>;
  forkOptions?: ForkOptions;
  maxRetries?: number;
  numWorkers?: number;
  resourceLimits?: ResourceLimits;
  setupArgs?: Array<unknown>;
  taskQueue?: TaskQueue;
  WorkerPool?: new (workerPath: string, options?: WorkerPoolOptions) => WorkerPoolInterface;
  workerSchedulingPolicy?: WorkerSchedulingPolicy;
  idleMemoryLimit?: number;
};
type WorkerPoolOptions = {
  setupArgs: Array<unknown>;
  forkOptions: ForkOptions;
  resourceLimits: ResourceLimits;
  maxRetries: number;
  numWorkers: number;
  enableWorkerThreads: boolean;
  idleMemoryLimit?: number;
};
type WorkerOptions = {
  forkOptions: ForkOptions;
  resourceLimits: ResourceLimits;
  setupArgs: Array<unknown>;
  maxRetries: number;
  workerId: number;
  workerData?: unknown;
  workerPath: string;
  /**
   * After a job has executed the memory usage it should return to.
   *
   * @remarks
   * Note this is different from ResourceLimits in that it checks at idle, after
   * a job is complete. So you could have a resource limit of 500MB but an idle
   * limit of 50MB. The latter will only trigger if after a job has completed the
   * memory usage hasn't returned back down under 50MB.
   */
  idleMemoryLimit?: number;
  /**
   * This mainly exists so the path can be changed during testing.
   * https://github.com/jestjs/jest/issues/9543
   */
  childWorkerPath?: string;
  /**
   * This is useful for debugging individual tests allowing you to see
   * the raw output of the worker.
   */
  silent?: boolean;
  /**
   * Used to immediately bind event handlers.
   */
  on?: {
    [WorkerEvents.STATE_CHANGE]: OnStateChangeHandler | ReadonlyArray<OnStateChangeHandler>;
  };
};
type OnStateChangeHandler = (state: WorkerStates, oldState: WorkerStates) => void;
type ChildMessageInitialize = [type: typeof CHILD_MESSAGE_INITIALIZE, isProcessed: boolean, fileName: string, setupArgs: Array<unknown>, workerId: string | undefined];
type ChildMessageCall = [type: typeof CHILD_MESSAGE_CALL, isProcessed: boolean, methodName: string, args: Array<unknown>];
type ChildMessageEnd = [type: typeof CHILD_MESSAGE_END, isProcessed: boolean];
type ChildMessageMemUsage = [type: typeof CHILD_MESSAGE_MEM_USAGE];
type ChildMessageCallSetup = [type: typeof CHILD_MESSAGE_CALL_SETUP];
type ChildMessage = ChildMessageInitialize | ChildMessageCall | ChildMessageEnd | ChildMessageMemUsage | ChildMessageCallSetup;
type OnStart = (worker: WorkerInterface) => void;
type OnEnd = (err: Error | null, result: unknown) => void;
type OnCustomMessage = (message: Array<unknown> | unknown) => void;
type QueueChildMessage = {
  request: ChildMessageCall;
  onStart: OnStart;
  onEnd: OnEnd;
  onCustomMessage: OnCustomMessage;
};
declare enum WorkerStates {
  STARTING = "starting",
  OK = "ok",
  OUT_OF_MEMORY = "oom",
  RESTARTING = "restarting",
  SHUTTING_DOWN = "shutting-down",
  SHUT_DOWN = "shut-down",
}
declare enum WorkerEvents {
  STATE_CHANGE = "state-change",
}
//#endregion
//#region src/PriorityQueue.d.ts
type ComputeTaskPriorityCallback = (method: string, ...args: Array<unknown>) => number;
type QueueItem = {
  task: QueueChildMessage;
  priority: number;
};
/**
 * Priority queue that processes tasks in natural ordering (lower priority first)
 * according to the priority computed by the function passed in the constructor.
 *
 * FIFO ordering isn't guaranteed for tasks with the same priority.
 *
 * Worker specific tasks with the same priority as a non-worker specific task
 * are always processed first.
 */
declare class PriorityQueue implements TaskQueue {
  private readonly _computePriority;
  private _queue;
  private readonly _sharedQueue;
  constructor(_computePriority: ComputeTaskPriorityCallback);
  enqueue(task: QueueChildMessage, workerId?: number): void;
  _enqueue(task: QueueChildMessage, queue: MinHeap<QueueItem>): void;
  dequeue(workerId: number): QueueChildMessage | null;
  _getWorkerQueue(workerId: number): MinHeap<QueueItem>;
}
type HeapItem = {
  priority: number;
};
declare class MinHeap<TItem extends HeapItem> {
  private readonly _heap;
  peek(): TItem | null;
  add(item: TItem): void;
  poll(): TItem | null;
}
//#endregion
//#region src/FifoQueue.d.ts
/**
 * First-in, First-out task queue that manages a dedicated pool
 * for each worker as well as a shared queue. The FIFO ordering is guaranteed
 * across the worker specific and shared queue.
 */
declare class FifoQueue implements TaskQueue {
  private _workerQueues;
  private readonly _sharedQueue;
  enqueue(task: QueueChildMessage, workerId?: number): void;
  dequeue(workerId: number): QueueChildMessage | null;
}
//#endregion
//#region src/workers/messageParent.d.ts
/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */
declare function messageParent(message: unknown, parentProcess?: NodeJS.Process): void;
//#endregion
//#region src/index.d.ts
type JestWorkerFarm<T extends Record<string, unknown>> = Worker & WorkerModule<T>;
/**
 * The Jest farm (publicly called "Worker") is a class that allows you to queue
 * methods across multiple child processes, in order to parallelize work. This
 * is done by providing an absolute path to a module that will be loaded on each
 * of the child processes, and bridged to the main process.
 *
 * Bridged methods are specified by using the "exposedMethods" property of the
 * "options" object. This is an array of strings, where each of them corresponds
 * to the exported name in the loaded module.
 *
 * You can also control the amount of workers by using the "numWorkers" property
 * of the "options" object, and the settings passed to fork the process through
 * the "forkOptions" property. The amount of workers defaults to the amount of
 * CPUS minus one.
 *
 * Queueing calls can be done in two ways:
 *   - Standard method: calls will be redirected to the first available worker,
 *     so they will get executed as soon as they can.
 *
 *   - Sticky method: if a "computeWorkerKey" method is provided within the
 *     config, the resulting string of this method will be used as a key.
 *     Every time this key is returned, it is guaranteed that your job will be
 *     processed by the same worker. This is specially useful if your workers
 *     are caching results.
 */
declare class Worker {
  private _ending;
  private readonly _farm;
  private readonly _options;
  private readonly _workerPool;
  constructor(workerPath: string | URL, options?: WorkerFarmOptions);
  private _bindExposedWorkerMethods;
  private _callFunctionWithArgs;
  getStderr(): NodeJS.ReadableStream;
  getStdout(): NodeJS.ReadableStream;
  start(): Promise<void>;
  end(): Promise<PoolExitResult>;
}
//#endregion
export { FifoQueue, JestWorkerFarm, PriorityQueue, PromiseWithCustomMessage, TaskQueue, Worker, WorkerFarmOptions, WorkerPoolInterface, WorkerPoolOptions, messageParent };