import { createRequire } from "node:module";
import { jestExpect } from "@jest/expect";
import { createEmptyTestResult } from "@jest/test-result";
import { formatExecError, formatResultsErrors } from "jest-message-util";
import { SnapshotState, addSerializer, buildSnapshotResolver } from "jest-snapshot";
import { bind } from "jest-each";
import { ErrorWithStack, convertDescriptorToString, formatTime, invariant, isPromise, protectProperties, setGlobal } from "jest-util";
import * as path from "path";
import co from "co";
import dedent from "dedent";
import isGeneratorFn from "is-generator-fn";
import slash from "slash";
import StackUtils from "stack-utils";
import { format } from "pretty-format";
import { AssertionError } from "assert";
import chalk from "chalk";
import { diff, printExpected, printReceived } from "jest-matcher-utils";
import { AsyncLocalStorage } from "async_hooks";
import pLimit from "p-limit";
import { unsafeUniformIntDistribution, xoroshiro128plus } from "pure-rand";

//#region rolldown:runtime
var __require = /* @__PURE__ */ createRequire(import.meta.url);

//#endregion
//#region src/globalErrorHandlers.ts
const uncaughtExceptionListener = (error) => {
	dispatchSync({
		error,
		name: "error"
	});
};
const unhandledRejectionListener = (error, promise) => {
	dispatchSync({
		error,
		name: "error",
		promise
	});
};
const rejectionHandledListener = (promise) => {
	dispatchSync({
		name: "error_handled",
		promise
	});
};
const injectGlobalErrorHandlers = (parentProcess) => {
	const uncaughtException = [...process.listeners("uncaughtException")];
	const unhandledRejection = [...process.listeners("unhandledRejection")];
	const rejectionHandled = [...process.listeners("rejectionHandled")];
	parentProcess.removeAllListeners("uncaughtException");
	parentProcess.removeAllListeners("unhandledRejection");
	parentProcess.removeAllListeners("rejectionHandled");
	parentProcess.on("uncaughtException", uncaughtExceptionListener);
	parentProcess.on("unhandledRejection", unhandledRejectionListener);
	parentProcess.on("rejectionHandled", rejectionHandledListener);
	return {
		rejectionHandled,
		uncaughtException,
		unhandledRejection
	};
};
const restoreGlobalErrorHandlers = (parentProcess, originalErrorHandlers) => {
	parentProcess.removeListener("uncaughtException", uncaughtExceptionListener);
	parentProcess.removeListener("unhandledRejection", unhandledRejectionListener);
	parentProcess.removeListener("rejectionHandled", rejectionHandledListener);
	for (const listener of originalErrorHandlers.uncaughtException) parentProcess.on("uncaughtException", listener);
	for (const listener of originalErrorHandlers.unhandledRejection) parentProcess.on("unhandledRejection", listener);
	for (const listener of originalErrorHandlers.rejectionHandled) parentProcess.on("rejectionHandled", listener);
};

//#endregion
//#region src/types.ts
/**
* Copyright (c) Meta Platforms, Inc. and affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/
const STATE_SYM = Symbol("JEST_STATE_SYMBOL");
const RETRY_TIMES = Symbol.for("RETRY_TIMES");
const RETRY_IMMEDIATELY = Symbol.for("RETRY_IMMEDIATELY");
const WAIT_BEFORE_RETRY = Symbol.for("WAIT_BEFORE_RETRY");
const TEST_TIMEOUT_SYMBOL = Symbol.for("TEST_TIMEOUT_SYMBOL");
const EVENT_HANDLERS = Symbol.for("EVENT_HANDLERS");
const LOG_ERRORS_BEFORE_RETRY = Symbol.for("LOG_ERRORS_BEFORE_RETRY");

//#endregion
//#region src/utils.ts
const stackUtils = new StackUtils({ cwd: "A path that does not exist" });
const jestEachBuildDir = slash(path.dirname(__require.resolve("jest-each")));
function takesDoneCallback(fn) {
	return fn.length > 0;
}
function isGeneratorFunction(fn) {
	return isGeneratorFn(fn);
}
const makeDescribe = (name, parent, mode) => {
	let _mode = mode;
	if (parent && !mode) _mode = parent.mode;
	return {
		type: "describeBlock",
		children: [],
		hooks: [],
		mode: _mode,
		name: convertDescriptorToString(name),
		parent,
		tests: []
	};
};
const makeTest = (fn, mode, concurrent, name, parent, timeout, asyncError, failing) => ({
	type: "test",
	asyncError,
	concurrent,
	duration: null,
	errors: [],
	failing,
	fn,
	invocations: 0,
	mode,
	name: convertDescriptorToString(name),
	numPassingAsserts: 0,
	parent,
	retryReasons: [],
	seenDone: false,
	startedAt: null,
	status: null,
	timeout,
	unhandledRejectionErrorByPromise: /* @__PURE__ */ new Map()
});
const hasEnabledTest = (describeBlock) => {
	const { hasFocusedTests, testNamePattern } = getState();
	return describeBlock.children.some((child) => child.type === "describeBlock" ? hasEnabledTest(child) : !(child.mode === "skip" || hasFocusedTests && child.mode !== "only" || testNamePattern && !testNamePattern.test(getTestID(child))));
};
const getAllHooksForDescribe = (describe$1) => {
	const result = {
		afterAll: [],
		beforeAll: []
	};
	if (hasEnabledTest(describe$1)) for (const hook of describe$1.hooks) switch (hook.type) {
		case "beforeAll":
			result.beforeAll.push(hook);
			break;
		case "afterAll":
			result.afterAll.push(hook);
			break;
	}
	return result;
};
const getEachHooksForTest = (test$1) => {
	const result = {
		afterEach: [],
		beforeEach: []
	};
	if (test$1.concurrent) return result;
	let block = test$1.parent;
	do {
		const beforeEachForCurrentBlock = [];
		for (const hook of block.hooks) switch (hook.type) {
			case "beforeEach":
				beforeEachForCurrentBlock.push(hook);
				break;
			case "afterEach":
				result.afterEach.push(hook);
				break;
		}
		result.beforeEach.unshift(...beforeEachForCurrentBlock);
	} while (block = block.parent);
	return result;
};
const describeBlockHasTests = (describe$1) => describe$1.children.some((child) => child.type === "test" || describeBlockHasTests(child));
const _makeTimeoutMessage = (timeout, isHook, takesDoneCallback$1) => `Exceeded timeout of ${formatTime(timeout)} for a ${isHook ? "hook" : "test"}${takesDoneCallback$1 ? " while waiting for `done()` to be called" : ""}.\nAdd a timeout value to this test to increase the timeout, if this is a long-running test. See https://jestjs.io/docs/api#testname-fn-timeout.`;
const { setTimeout: setTimeout$2, clearTimeout } = globalThis;
function checkIsError(error) {
	return !!(error && error.message && error.stack);
}
const callAsyncCircusFn = (testOrHook, testContext, { isHook, timeout }) => {
	let timeoutID;
	let completed = false;
	const { fn, asyncError } = testOrHook;
	const doneCallback = takesDoneCallback(fn);
	return new Promise((resolve, reject) => {
		timeoutID = setTimeout$2(() => reject(_makeTimeoutMessage(timeout, isHook, doneCallback)), timeout);
		if (doneCallback) {
			let returnedValue$1 = void 0;
			const done = (reason) => {
				const errorAtDone = new ErrorWithStack(void 0, done);
				if (!completed && testOrHook.seenDone) {
					errorAtDone.message = "Expected done to be called once, but it was called multiple times.";
					if (reason) errorAtDone.message += ` Reason: ${format(reason, { maxDepth: 3 })}`;
					reject(errorAtDone);
					throw errorAtDone;
				} else testOrHook.seenDone = true;
				Promise.resolve().then(() => {
					if (returnedValue$1 !== void 0) {
						asyncError.message = dedent`
              Test functions cannot both take a 'done' callback and return something. Either use a 'done' callback, or return a promise.
              Returned value: ${format(returnedValue$1, { maxDepth: 3 })}
            `;
						return reject(asyncError);
					}
					let errorAsErrorObject;
					if (checkIsError(reason)) errorAsErrorObject = reason;
					else {
						errorAsErrorObject = errorAtDone;
						errorAtDone.message = `Failed: ${format(reason, { maxDepth: 3 })}`;
					}
					if (completed && reason) {
						errorAsErrorObject.message = `Caught error after test environment was torn down\n\n${errorAsErrorObject.message}`;
						throw errorAsErrorObject;
					}
					return reason ? reject(errorAsErrorObject) : resolve();
				});
			};
			returnedValue$1 = fn.call(testContext, done);
			return;
		}
		let returnedValue;
		if (isGeneratorFunction(fn)) returnedValue = co.wrap(fn).call({});
		else try {
			returnedValue = fn.call(testContext);
		} catch (error) {
			reject(error);
			return;
		}
		if (isPromise(returnedValue)) {
			returnedValue.then(() => resolve(), reject);
			return;
		}
		if (!isHook && returnedValue !== void 0) {
			reject(new Error(dedent`
            test functions can only return Promise or undefined.
            Returned value: ${format(returnedValue, { maxDepth: 3 })}
          `));
			return;
		}
		resolve();
	}).finally(() => {
		completed = true;
		timeoutID.unref?.();
		clearTimeout(timeoutID);
	});
};
const getTestDuration = (test$1) => {
	const { startedAt } = test$1;
	return typeof startedAt === "number" ? Date.now() - startedAt : null;
};
const makeRunResult = (describeBlock, unhandledErrors) => ({
	testResults: makeTestResults(describeBlock),
	unhandledErrors: unhandledErrors.map(_getError).map(getErrorStack)
});
const getTestNamesPath = (test$1) => {
	const titles = [];
	let parent = test$1;
	do
		titles.unshift(parent.name);
	while (parent = parent.parent);
	return titles;
};
const makeSingleTestResult = (test$1) => {
	const { includeTestLocationInResult } = getState();
	const { status } = test$1;
	invariant(status, "Status should be present after tests are run.");
	const testPath = getTestNamesPath(test$1);
	let location = null;
	if (includeTestLocationInResult) {
		const stackLines = test$1.asyncError.stack.split("\n");
		const stackLine = stackLines[1];
		let parsedLine = stackUtils.parseLine(stackLine);
		if (parsedLine?.file?.startsWith(jestEachBuildDir)) {
			const stackLine$1 = stackLines[2];
			parsedLine = stackUtils.parseLine(stackLine$1);
		}
		if (parsedLine && typeof parsedLine.column === "number" && typeof parsedLine.line === "number") location = {
			column: parsedLine.column,
			line: parsedLine.line
		};
	}
	const errorsDetailed = test$1.errors.map(_getError);
	return {
		duration: test$1.duration,
		errors: errorsDetailed.map(getErrorStack),
		errorsDetailed,
		failing: test$1.failing,
		invocations: test$1.invocations,
		location,
		numPassingAsserts: test$1.numPassingAsserts,
		retryReasons: test$1.retryReasons.map(_getError).map(getErrorStack),
		startedAt: test$1.startedAt,
		status,
		testPath: [...testPath]
	};
};
const makeTestResults = (describeBlock) => {
	const testResults = [];
	const stack = [[describeBlock, 0]];
	while (stack.length > 0) {
		const [currentBlock, childIndex] = stack.pop();
		for (let i = childIndex; i < currentBlock.children.length; i++) {
			const child = currentBlock.children[i];
			if (child.type === "describeBlock") {
				stack.push([currentBlock, i + 1], [child, 0]);
				break;
			}
			if (child.type === "test") testResults.push(makeSingleTestResult(child));
		}
	}
	return testResults;
};
const getTestID = (test$1) => {
	const testNamesPath = getTestNamesPath(test$1);
	testNamesPath.shift();
	return testNamesPath.join(" ");
};
const _getError = (errors) => {
	let error;
	let asyncError;
	if (Array.isArray(errors)) {
		error = errors[0];
		asyncError = errors[1];
	} else {
		error = errors;
		asyncError = new Error();
	}
	if (error && (typeof error.stack === "string" || error.message)) return error;
	asyncError.message = `thrown: ${format(error, { maxDepth: 3 })}`;
	return asyncError;
};
const getErrorStack = (error) => typeof error.stack === "string" ? error.stack : error.message;
const addErrorToEachTestUnderDescribe = (describeBlock, error, asyncError) => {
	for (const child of describeBlock.children) switch (child.type) {
		case "describeBlock":
			addErrorToEachTestUnderDescribe(child, error, asyncError);
			break;
		case "test":
			child.errors.push([error, asyncError]);
			break;
	}
};
const resolveTestCaseStartInfo = (testNamesPath) => {
	const ancestorTitles = testNamesPath.filter((name) => name !== ROOT_DESCRIBE_BLOCK_NAME);
	const fullName = ancestorTitles.join(" ");
	const title = testNamesPath.at(-1);
	ancestorTitles.pop();
	return {
		ancestorTitles,
		fullName,
		title
	};
};
const parseSingleTestResult = (testResult) => {
	let status;
	if (testResult.status === "skip") status = "pending";
	else if (testResult.status === "todo") status = "todo";
	else if (testResult.errors.length > 0) status = "failed";
	else status = "passed";
	const { ancestorTitles, fullName, title } = resolveTestCaseStartInfo(testResult.testPath);
	return {
		ancestorTitles,
		duration: testResult.duration,
		failing: testResult.failing,
		failureDetails: testResult.errorsDetailed,
		failureMessages: [...testResult.errors],
		fullName,
		invocations: testResult.invocations,
		location: testResult.location,
		numPassingAsserts: testResult.numPassingAsserts,
		retryReasons: [...testResult.retryReasons],
		startedAt: testResult.startedAt,
		status,
		title
	};
};
const createTestCaseStartInfo = (test$1) => {
	const testPath = getTestNamesPath(test$1);
	const { ancestorTitles, fullName, title } = resolveTestCaseStartInfo(testPath);
	return {
		ancestorTitles,
		fullName,
		mode: test$1.mode,
		startedAt: test$1.startedAt,
		title
	};
};

//#endregion
//#region src/eventHandler.ts
const eventHandler$1 = (event, state) => {
	switch (event.name) {
		case "include_test_location_in_result": {
			state.includeTestLocationInResult = true;
			break;
		}
		case "hook_start": {
			event.hook.seenDone = false;
			break;
		}
		case "start_describe_definition": {
			const { blockName, mode } = event;
			const { currentDescribeBlock, currentlyRunningTest } = state;
			if (currentlyRunningTest) {
				currentlyRunningTest.errors.push(new Error(`Cannot nest a describe inside a test. Describe block "${blockName}" cannot run because it is nested within "${currentlyRunningTest.name}".`));
				break;
			}
			const describeBlock = makeDescribe(blockName, currentDescribeBlock, mode);
			currentDescribeBlock.children.push(describeBlock);
			state.currentDescribeBlock = describeBlock;
			break;
		}
		case "finish_describe_definition": {
			const { currentDescribeBlock } = state;
			invariant(currentDescribeBlock, "currentDescribeBlock must be there");
			if (!describeBlockHasTests(currentDescribeBlock)) for (const hook of currentDescribeBlock.hooks) {
				hook.asyncError.message = `Invalid: ${hook.type}() may not be used in a describe block containing no tests.`;
				state.unhandledErrors.push(hook.asyncError);
			}
			const shouldPassMode = !(currentDescribeBlock.mode === "only" && currentDescribeBlock.children.some((child) => child.type === "test" && child.mode === "only"));
			if (shouldPassMode) {
				for (const child of currentDescribeBlock.children) if (child.type === "test" && !child.mode) child.mode = currentDescribeBlock.mode;
			}
			if (!state.hasFocusedTests && currentDescribeBlock.mode !== "skip" && currentDescribeBlock.children.some((child) => child.type === "test" && child.mode === "only")) state.hasFocusedTests = true;
			if (currentDescribeBlock.parent) state.currentDescribeBlock = currentDescribeBlock.parent;
			break;
		}
		case "add_hook": {
			const { currentDescribeBlock, currentlyRunningTest, hasStarted } = state;
			const { asyncError, fn, hookType: type, timeout } = event;
			if (currentlyRunningTest) {
				currentlyRunningTest.errors.push(new Error(`Hooks cannot be defined inside tests. Hook of type "${type}" is nested within "${currentlyRunningTest.name}".`));
				break;
			} else if (hasStarted) {
				state.unhandledErrors.push(new Error("Cannot add a hook after tests have started running. Hooks must be defined synchronously."));
				break;
			}
			const parent = currentDescribeBlock;
			currentDescribeBlock.hooks.push({
				asyncError,
				fn,
				parent,
				seenDone: false,
				timeout,
				type
			});
			break;
		}
		case "add_test": {
			const { currentDescribeBlock, currentlyRunningTest, hasStarted } = state;
			const { asyncError, fn, mode, testName: name, timeout, concurrent, failing } = event;
			if (currentlyRunningTest) {
				currentlyRunningTest.errors.push(new Error(`Tests cannot be nested. Test "${name}" cannot run because it is nested within "${currentlyRunningTest.name}".`));
				break;
			} else if (hasStarted) {
				state.unhandledErrors.push(new Error("Cannot add a test after tests have started running. Tests must be defined synchronously."));
				break;
			}
			const test$1 = makeTest(fn, mode, concurrent, name, currentDescribeBlock, timeout, asyncError, failing);
			if (currentDescribeBlock.mode !== "skip" && test$1.mode === "only") state.hasFocusedTests = true;
			currentDescribeBlock.children.push(test$1);
			currentDescribeBlock.tests.push(test$1);
			break;
		}
		case "hook_failure": {
			const { test: test$1, describeBlock, error, hook } = event;
			const { asyncError, type } = hook;
			if (type === "beforeAll") {
				invariant(describeBlock, "always present for `*All` hooks");
				addErrorToEachTestUnderDescribe(describeBlock, error, asyncError);
			} else if (type === "afterAll") state.unhandledErrors.push([error, asyncError]);
			else {
				invariant(test$1, "always present for `*Each` hooks");
				test$1.errors.push([error, asyncError]);
			}
			break;
		}
		case "test_skip": {
			event.test.status = "skip";
			break;
		}
		case "test_todo": {
			event.test.status = "todo";
			break;
		}
		case "test_done": {
			event.test.duration = getTestDuration(event.test);
			event.test.status = "done";
			state.currentlyRunningTest = null;
			break;
		}
		case "test_start": {
			state.currentlyRunningTest = event.test;
			event.test.startedAt = Date.now();
			event.test.invocations += 1;
			break;
		}
		case "test_fn_start": {
			event.test.seenDone = false;
			break;
		}
		case "test_fn_failure": {
			const { error, test: { asyncError } } = event;
			event.test.errors.push([error, asyncError]);
			break;
		}
		case "test_retry": {
			const logErrorsBeforeRetry = globalThis[LOG_ERRORS_BEFORE_RETRY] || false;
			if (logErrorsBeforeRetry) event.test.retryReasons.push(...event.test.errors);
			event.test.errors = [];
			break;
		}
		case "run_start": {
			state.hasStarted = true;
			if (globalThis[TEST_TIMEOUT_SYMBOL]) state.testTimeout = globalThis[TEST_TIMEOUT_SYMBOL];
			break;
		}
		case "run_finish": break;
		case "setup": {
			state.parentProcess = event.parentProcess;
			invariant(state.parentProcess);
			state.originalGlobalErrorHandlers = injectGlobalErrorHandlers(state.parentProcess);
			if (event.testNamePattern) state.testNamePattern = new RegExp(event.testNamePattern, "i");
			break;
		}
		case "teardown": {
			invariant(state.originalGlobalErrorHandlers);
			invariant(state.parentProcess);
			restoreGlobalErrorHandlers(state.parentProcess, state.originalGlobalErrorHandlers);
			break;
		}
		case "error": {
			if (state.currentlyRunningTest) if (event.promise) state.currentlyRunningTest.unhandledRejectionErrorByPromise.set(event.promise, event.error);
			else state.currentlyRunningTest.errors.push(event.error);
			else if (event.promise) state.unhandledRejectionErrorByPromise.set(event.promise, event.error);
			else state.unhandledErrors.push(event.error);
			break;
		}
		case "error_handled": {
			if (state.currentlyRunningTest) state.currentlyRunningTest.unhandledRejectionErrorByPromise.delete(event.promise);
			else state.unhandledRejectionErrorByPromise.delete(event.promise);
			break;
		}
	}
};
var eventHandler_default = eventHandler$1;

//#endregion
//#region src/formatNodeAssertErrors.ts
const assertOperatorsMap = {
	"!=": "notEqual",
	"!==": "notStrictEqual",
	"==": "equal",
	"===": "strictEqual"
};
const humanReadableOperators = {
	deepEqual: "to deeply equal",
	deepStrictEqual: "to deeply and strictly equal",
	equal: "to be equal",
	notDeepEqual: "not to deeply equal",
	notDeepStrictEqual: "not to deeply and strictly equal",
	notEqual: "to not be equal",
	notStrictEqual: "not be strictly equal",
	strictEqual: "to strictly be equal"
};
const formatNodeAssertErrors = (event, state) => {
	if (event.name === "test_done") event.test.errors = event.test.errors.map((errors) => {
		let error;
		if (Array.isArray(errors)) {
			const [originalError, asyncError] = errors;
			if (originalError == null) error = asyncError;
			else if (originalError.stack) error = originalError;
			else {
				error = asyncError;
				error.message = originalError.message || `thrown: ${format(originalError, { maxDepth: 3 })}`;
			}
		} else error = errors;
		return isAssertionError(error) ? { message: assertionErrorMessage(error, { expand: state.expand }) } : errors;
	});
};
const getOperatorName = (operator, stack) => {
	if (typeof operator === "string") return assertOperatorsMap[operator] || operator;
	if (stack.match(".doesNotThrow")) return "doesNotThrow";
	if (stack.match(".throws")) return "throws";
	return "";
};
const operatorMessage = (operator) => {
	const niceOperatorName = getOperatorName(operator, "");
	const humanReadableOperator = humanReadableOperators[niceOperatorName];
	return typeof operator === "string" ? `${humanReadableOperator || niceOperatorName} to:\n` : "";
};
const assertThrowingMatcherHint = (operatorName) => operatorName ? chalk.dim("assert") + chalk.dim(`.${operatorName}(`) + chalk.red("function") + chalk.dim(")") : "";
const assertMatcherHint = (operator, operatorName, expected) => {
	let message = "";
	if (operator === "==" && expected === true) message = chalk.dim("assert") + chalk.dim("(") + chalk.red("received") + chalk.dim(")");
	else if (operatorName) message = chalk.dim("assert") + chalk.dim(`.${operatorName}(`) + chalk.red("received") + chalk.dim(", ") + chalk.green("expected") + chalk.dim(")");
	return message;
};
function assertionErrorMessage(error, options) {
	const { expected, actual, generatedMessage, message, operator, stack } = error;
	const diffString = diff(expected, actual, options);
	const hasCustomMessage = !generatedMessage;
	const operatorName = getOperatorName(operator, stack);
	const trimmedStack = stack.replace(message, "").replaceAll(/AssertionError(.*)/g, "");
	if (operatorName === "doesNotThrow") return buildHintString(assertThrowingMatcherHint(operatorName)) + chalk.reset("Expected the function not to throw an error.\n") + chalk.reset("Instead, it threw:\n") + `  ${printReceived(actual)}` + chalk.reset(hasCustomMessage ? `\n\nMessage:\n  ${message}` : "") + trimmedStack;
	if (operatorName === "throws") {
		if (error.generatedMessage) return buildHintString(assertThrowingMatcherHint(operatorName)) + chalk.reset(error.message) + chalk.reset(hasCustomMessage ? `\n\nMessage:\n  ${message}` : "") + trimmedStack;
		return buildHintString(assertThrowingMatcherHint(operatorName)) + chalk.reset("Expected the function to throw an error.\n") + chalk.reset("But it didn't throw anything.") + chalk.reset(hasCustomMessage ? `\n\nMessage:\n  ${message}` : "") + trimmedStack;
	}
	if (operatorName === "fail") return buildHintString(assertMatcherHint(operator, operatorName, expected)) + chalk.reset(hasCustomMessage ? `Message:\n  ${message}` : "") + trimmedStack;
	return buildHintString(assertMatcherHint(operator, operatorName, expected)) + chalk.reset(`Expected value ${operatorMessage(operator)}`) + `  ${printExpected(expected)}\n` + chalk.reset("Received:\n") + `  ${printReceived(actual)}` + chalk.reset(hasCustomMessage ? `\n\nMessage:\n  ${message}` : "") + (diffString ? `\n\nDifference:\n\n${diffString}` : "") + trimmedStack;
}
function isAssertionError(error) {
	return error && (error instanceof AssertionError || error.name === AssertionError.name || error.code === "ERR_ASSERTION");
}
function buildHintString(hint) {
	return hint ? `${hint}\n\n` : "";
}
var formatNodeAssertErrors_default = formatNodeAssertErrors;

//#endregion
//#region src/state.ts
const handlers = globalThis[EVENT_HANDLERS] || [eventHandler_default, formatNodeAssertErrors_default];
setGlobal(globalThis, EVENT_HANDLERS, handlers, "retain");
const ROOT_DESCRIBE_BLOCK_NAME = "ROOT_DESCRIBE_BLOCK";
const createState = () => {
	const ROOT_DESCRIBE_BLOCK = makeDescribe(ROOT_DESCRIBE_BLOCK_NAME);
	return {
		currentDescribeBlock: ROOT_DESCRIBE_BLOCK,
		currentlyRunningTest: null,
		expand: void 0,
		hasFocusedTests: false,
		hasStarted: false,
		includeTestLocationInResult: false,
		maxConcurrency: 5,
		parentProcess: null,
		rootDescribeBlock: ROOT_DESCRIBE_BLOCK,
		seed: 0,
		testNamePattern: null,
		testTimeout: 5e3,
		unhandledErrors: [],
		unhandledRejectionErrorByPromise: /* @__PURE__ */ new Map()
	};
};
const getState = () => globalThis[STATE_SYM];
const setState = (state) => {
	setGlobal(globalThis, STATE_SYM, state);
	protectProperties(state, [
		"hasFocusedTests",
		"hasStarted",
		"includeTestLocationInResult",
		"maxConcurrency",
		"seed",
		"testNamePattern",
		"testTimeout",
		"unhandledErrors",
		"unhandledRejectionErrorByPromise"
	]);
	return state;
};
const resetState = () => {
	setState(createState());
};
resetState();
const dispatch = async (event) => {
	for (const handler of handlers) await handler(event, getState());
};
const dispatchSync = (event) => {
	for (const handler of handlers) handler(event, getState());
};
const addEventHandler = (handler) => {
	handlers.push(handler);
};

//#endregion
//#region src/shuffleArray.ts
const rngBuilder = (seed) => {
	const gen = xoroshiro128plus(seed);
	return { next: (from, to) => unsafeUniformIntDistribution(from, to, gen) };
};
function shuffleArray(array, random) {
	const length = array.length;
	if (length === 0) return [];
	for (let i = 0; i < length; i++) {
		const n = random.next(i, length - 1);
		const value = array[i];
		array[i] = array[n];
		array[n] = value;
	}
	return array;
}

//#endregion
//#region src/run.ts
const { setTimeout: setTimeout$1 } = globalThis;
const run = async () => {
	const { rootDescribeBlock, seed, randomize } = getState();
	const rng = randomize ? rngBuilder(seed) : void 0;
	await dispatch({ name: "run_start" });
	await _runTestsForDescribeBlock(rootDescribeBlock, rng, true);
	await dispatch({ name: "run_finish" });
	return makeRunResult(getState().rootDescribeBlock, getState().unhandledErrors);
};
const _runTestsForDescribeBlock = async (describeBlock, rng, isRootBlock = false) => {
	await dispatch({
		describeBlock,
		name: "run_describe_start"
	});
	const { beforeAll: beforeAll$1, afterAll: afterAll$1 } = getAllHooksForDescribe(describeBlock);
	const isSkipped = describeBlock.mode === "skip";
	if (!isSkipped) for (const hook of beforeAll$1) await _callCircusHook({
		describeBlock,
		hook
	});
	if (isRootBlock) {
		const concurrentTests$1 = collectConcurrentTests(describeBlock);
		if (concurrentTests$1.length > 0) startTestsConcurrently(concurrentTests$1, isSkipped);
	}
	const retryTimes = Number.parseInt(globalThis[RETRY_TIMES], 10) || 0;
	const waitBeforeRetry = Number.parseInt(globalThis[WAIT_BEFORE_RETRY], 10) || 0;
	const retryImmediately = globalThis[RETRY_IMMEDIATELY] || false;
	const deferredRetryTests = [];
	if (rng) describeBlock.children = shuffleArray(describeBlock.children, rng);
	const rerunTest = async (test$1) => {
		let numRetriesAvailable = retryTimes;
		while (numRetriesAvailable > 0 && test$1.errors.length > 0) {
			await dispatch({
				name: "test_retry",
				test: test$1
			});
			if (waitBeforeRetry > 0) await new Promise((resolve) => setTimeout$1(resolve, waitBeforeRetry));
			await _runTest(test$1, isSkipped);
			numRetriesAvailable--;
		}
	};
	const handleRetry = async (test$1, hasErrorsBeforeTestRun, hasRetryTimes) => {
		if (test$1.errors.length === 0 || hasErrorsBeforeTestRun || !hasRetryTimes) return;
		if (!retryImmediately) {
			deferredRetryTests.push(test$1);
			return;
		}
		await rerunTest(test$1);
	};
	const concurrentTests = [];
	for (const child of describeBlock.children) switch (child.type) {
		case "describeBlock": {
			await _runTestsForDescribeBlock(child, rng);
			break;
		}
		case "test": {
			const hasErrorsBeforeTestRun = child.errors.length > 0;
			const hasRetryTimes = retryTimes > 0;
			if (child.concurrent) concurrentTests.push(child.done.then(() => handleRetry(child, hasErrorsBeforeTestRun, hasRetryTimes)));
			else {
				await _runTest(child, isSkipped);
				await handleRetry(child, hasErrorsBeforeTestRun, hasRetryTimes);
			}
			break;
		}
	}
	await Promise.all(concurrentTests);
	for (const test$1 of deferredRetryTests) await rerunTest(test$1);
	if (!isSkipped) for (const hook of afterAll$1) await _callCircusHook({
		describeBlock,
		hook
	});
	await dispatch({
		describeBlock,
		name: "run_describe_finish"
	});
};
function collectConcurrentTests(describeBlock) {
	if (describeBlock.mode === "skip") return [];
	return describeBlock.children.flatMap((child) => {
		switch (child.type) {
			case "describeBlock": return collectConcurrentTests(child);
			case "test":
				if (child.concurrent) return [child];
				return [];
		}
	});
}
function startTestsConcurrently(concurrentTests, parentSkipped) {
	const mutex = pLimit(getState().maxConcurrency);
	const testNameStorage = new AsyncLocalStorage();
	jestExpect.setState({ currentConcurrentTestName: () => testNameStorage.getStore() });
	for (const test$1 of concurrentTests) try {
		const promise = mutex(() => testNameStorage.run(getTestID(test$1), () => _runTest(test$1, parentSkipped)));
		promise.catch(() => {});
		test$1.done = promise;
	} catch (error) {
		test$1.fn = () => {
			throw error;
		};
	}
}
const _runTest = async (test$1, parentSkipped) => {
	await dispatch({
		name: "test_start",
		test: test$1
	});
	const testContext = Object.create(null);
	const { hasFocusedTests, testNamePattern } = getState();
	const isSkipped = parentSkipped || test$1.mode === "skip" || hasFocusedTests && test$1.mode === void 0 || testNamePattern && !testNamePattern.test(getTestID(test$1));
	if (isSkipped) {
		await dispatch({
			name: "test_skip",
			test: test$1
		});
		return;
	}
	if (test$1.mode === "todo") {
		await dispatch({
			name: "test_todo",
			test: test$1
		});
		return;
	}
	await dispatch({
		name: "test_started",
		test: test$1
	});
	const { afterEach: afterEach$1, beforeEach: beforeEach$1 } = getEachHooksForTest(test$1);
	for (const hook of beforeEach$1) {
		if (test$1.errors.length > 0) break;
		await _callCircusHook({
			hook,
			test: test$1,
			testContext
		});
	}
	await _callCircusTest(test$1, testContext);
	for (const hook of afterEach$1) await _callCircusHook({
		hook,
		test: test$1,
		testContext
	});
	await dispatch({
		name: "test_done",
		test: test$1
	});
};
const _callCircusHook = async ({ hook, test: test$1, describeBlock, testContext = {} }) => {
	await dispatch({
		hook,
		name: "hook_start"
	});
	const timeout = hook.timeout || getState().testTimeout;
	try {
		await callAsyncCircusFn(hook, testContext, {
			isHook: true,
			timeout
		});
		await dispatch({
			describeBlock,
			hook,
			name: "hook_success",
			test: test$1
		});
	} catch (error) {
		await dispatch({
			describeBlock,
			error,
			hook,
			name: "hook_failure",
			test: test$1
		});
	}
};
const _callCircusTest = async (test$1, testContext) => {
	await dispatch({
		name: "test_fn_start",
		test: test$1
	});
	const timeout = test$1.timeout || getState().testTimeout;
	invariant(test$1.fn, "Tests with no 'fn' should have 'mode' set to 'skipped'");
	if (test$1.errors.length > 0) return;
	try {
		await callAsyncCircusFn(test$1, testContext, {
			isHook: false,
			timeout
		});
		if (test$1.failing) {
			test$1.asyncError.message = "Failing test passed even though it was supposed to fail. Remove `.failing` to remove error.";
			await dispatch({
				error: test$1.asyncError,
				name: "test_fn_failure",
				test: test$1
			});
		} else await dispatch({
			name: "test_fn_success",
			test: test$1
		});
	} catch (error) {
		if (test$1.failing) await dispatch({
			name: "test_fn_success",
			test: test$1
		});
		else await dispatch({
			error,
			name: "test_fn_failure",
			test: test$1
		});
	}
};
var run_default = run;

//#endregion
//#region src/index.ts
const describe = (() => {
	const describe$1 = (blockName, blockFn) => _dispatchDescribe(blockFn, blockName, describe$1);
	const only = (blockName, blockFn) => _dispatchDescribe(blockFn, blockName, only, "only");
	const skip = (blockName, blockFn) => _dispatchDescribe(blockFn, blockName, skip, "skip");
	describe$1.each = bind(describe$1, false);
	only.each = bind(only, false);
	skip.each = bind(skip, false);
	describe$1.only = only;
	describe$1.skip = skip;
	return describe$1;
})();
const _dispatchDescribe = (blockFn, blockName, describeFn, mode) => {
	const asyncError = new ErrorWithStack(void 0, describeFn);
	if (blockFn === void 0) {
		asyncError.message = "Missing second argument. It must be a callback function.";
		throw asyncError;
	}
	if (typeof blockFn !== "function") {
		asyncError.message = `Invalid second argument, ${blockFn}. It must be a callback function.`;
		throw asyncError;
	}
	try {
		blockName = convertDescriptorToString(blockName);
	} catch (error) {
		asyncError.message = error.message;
		throw asyncError;
	}
	dispatchSync({
		asyncError,
		blockName,
		mode,
		name: "start_describe_definition"
	});
	const describeReturn = blockFn();
	if (isPromise(describeReturn)) throw new ErrorWithStack("Returning a Promise from \"describe\" is not supported. Tests must be defined synchronously.", describeFn);
	else if (describeReturn !== void 0) throw new ErrorWithStack("A \"describe\" callback must not return a value.", describeFn);
	dispatchSync({
		blockName,
		mode,
		name: "finish_describe_definition"
	});
};
const _addHook = (fn, hookType, hookFn, timeout) => {
	const asyncError = new ErrorWithStack(void 0, hookFn);
	if (typeof fn !== "function") {
		asyncError.message = "Invalid first argument. It must be a callback function.";
		throw asyncError;
	}
	dispatchSync({
		asyncError,
		fn,
		hookType,
		name: "add_hook",
		timeout
	});
};
const beforeEach = (fn, timeout) => _addHook(fn, "beforeEach", beforeEach, timeout);
const beforeAll = (fn, timeout) => _addHook(fn, "beforeAll", beforeAll, timeout);
const afterEach = (fn, timeout) => _addHook(fn, "afterEach", afterEach, timeout);
const afterAll = (fn, timeout) => _addHook(fn, "afterAll", afterAll, timeout);
const test = (() => {
	const test$1 = (testName, fn, timeout) => _addTest(testName, void 0, false, fn, test$1, timeout);
	const skip = (testName, fn, timeout) => _addTest(testName, "skip", false, fn, skip, timeout);
	const only = (testName, fn, timeout) => _addTest(testName, "only", false, fn, test$1.only, timeout);
	const concurrentTest = (testName, fn, timeout) => _addTest(testName, void 0, true, fn, concurrentTest, timeout);
	const concurrentOnly = (testName, fn, timeout) => _addTest(testName, "only", true, fn, concurrentOnly, timeout);
	const bindFailing = (concurrent, mode) => {
		const failing = (testName, fn, timeout, eachError) => _addTest(testName, mode, concurrent, fn, failing, timeout, true, eachError);
		failing.each = bind(failing, false, true);
		return failing;
	};
	test$1.todo = (testName, ...rest) => {
		if (rest.length > 0 || typeof testName !== "string") throw new ErrorWithStack("Todo must be called with only a description.", test$1.todo);
		return _addTest(testName, "todo", false, () => {}, test$1.todo);
	};
	const _addTest = (testName, mode, concurrent, fn, testFn, timeout, failing, asyncError = new ErrorWithStack(void 0, testFn)) => {
		try {
			testName = convertDescriptorToString(testName);
		} catch (error) {
			asyncError.message = error.message;
			throw asyncError;
		}
		if (fn === void 0) {
			asyncError.message = "Missing second argument. It must be a callback function. Perhaps you want to use `test.todo` for a test placeholder.";
			throw asyncError;
		}
		if (typeof fn !== "function") {
			asyncError.message = `Invalid second argument, ${fn}. It must be a callback function.`;
			throw asyncError;
		}
		return dispatchSync({
			asyncError,
			concurrent,
			failing: failing === void 0 ? false : failing,
			fn,
			mode,
			name: "add_test",
			testName,
			timeout
		});
	};
	test$1.each = bind(test$1);
	only.each = bind(only);
	skip.each = bind(skip);
	concurrentTest.each = bind(concurrentTest, false);
	concurrentOnly.each = bind(concurrentOnly, false);
	only.failing = bindFailing(false, "only");
	skip.failing = bindFailing(false, "skip");
	test$1.failing = bindFailing(false);
	test$1.only = only;
	test$1.skip = skip;
	test$1.concurrent = concurrentTest;
	concurrentTest.only = concurrentOnly;
	concurrentTest.skip = skip;
	concurrentTest.failing = bindFailing(true);
	concurrentOnly.failing = bindFailing(true, "only");
	return test$1;
})();
const it = test;
var src_default = {
	afterAll,
	afterEach,
	beforeAll,
	beforeEach,
	describe,
	it,
	test
};

//#endregion
//#region src/testCaseReportHandler.ts
const testCaseReportHandler = (testPath, sendMessageToJest) => (event) => {
	switch (event.name) {
		case "test_started": {
			const testCaseStartInfo = createTestCaseStartInfo(event.test);
			sendMessageToJest("test-case-start", [testPath, testCaseStartInfo]);
			break;
		}
		case "test_todo":
		case "test_done": {
			const testResult = makeSingleTestResult(event.test);
			const testCaseResult = parseSingleTestResult(testResult);
			sendMessageToJest("test-case-result", [testPath, testCaseResult]);
			break;
		}
	}
};
var testCaseReportHandler_default = testCaseReportHandler;

//#endregion
//#region src/unhandledRejectionHandler.ts
const { setTimeout } = globalThis;
const untilNextEventLoopTurn = async () => {
	return new Promise((resolve) => {
		setTimeout(resolve, 0);
	});
};
const unhandledRejectionHandler = (runtime, waitForUnhandledRejections) => {
	return async (event, state) => {
		if (event.name === "hook_start") runtime.enterTestCode();
		else if (event.name === "hook_success" || event.name === "hook_failure") {
			runtime.leaveTestCode();
			if (waitForUnhandledRejections) await untilNextEventLoopTurn();
			const { test: test$1, describeBlock, hook } = event;
			const { asyncError, type } = hook;
			if (type === "beforeAll") {
				invariant(describeBlock, "always present for `*All` hooks");
				for (const error of state.unhandledRejectionErrorByPromise.values()) addErrorToEachTestUnderDescribe(describeBlock, error, asyncError);
			} else if (type === "afterAll") for (const error of state.unhandledRejectionErrorByPromise.values()) state.unhandledErrors.push([error, asyncError]);
			else {
				invariant(test$1, "always present for `*Each` hooks");
				for (const error of test$1.unhandledRejectionErrorByPromise.values()) test$1.errors.push([error, asyncError]);
			}
		} else if (event.name === "test_fn_start") runtime.enterTestCode();
		else if (event.name === "test_fn_success" || event.name === "test_fn_failure") {
			runtime.leaveTestCode();
			if (waitForUnhandledRejections) await untilNextEventLoopTurn();
			const { test: test$1 } = event;
			invariant(test$1, "always present for `*Each` hooks");
			for (const error of test$1.unhandledRejectionErrorByPromise.values()) test$1.errors.push([error, event.test.asyncError]);
		} else if (event.name === "teardown") {
			if (waitForUnhandledRejections) await untilNextEventLoopTurn();
			state.unhandledErrors.push(...state.unhandledRejectionErrorByPromise.values());
		}
	};
};

//#endregion
//#region src/legacy-code-todo-rewrite/jestAdapterInit.ts
const initialize = async ({ config, environment, runtime, globalConfig, localRequire, parentProcess, sendMessageToJest, setGlobalsForRuntime, testPath }) => {
	if (globalConfig.testTimeout) getState().testTimeout = globalConfig.testTimeout;
	getState().maxConcurrency = globalConfig.maxConcurrency;
	getState().randomize = globalConfig.randomize;
	getState().seed = globalConfig.seed;
	const globalsObject = {
		...src_default,
		fdescribe: src_default.describe.only,
		fit: src_default.it.only,
		xdescribe: src_default.describe.skip,
		xit: src_default.it.skip,
		xtest: src_default.it.skip
	};
	addEventHandler(eventHandler);
	if (environment.handleTestEvent) addEventHandler(environment.handleTestEvent.bind(environment));
	jestExpect.setState({ expand: globalConfig.expand });
	const runtimeGlobals = {
		...globalsObject,
		expect: jestExpect
	};
	setGlobalsForRuntime(runtimeGlobals);
	if (config.injectGlobals) Object.assign(environment.global, runtimeGlobals);
	await dispatch({
		name: "setup",
		parentProcess,
		runtimeGlobals,
		testNamePattern: globalConfig.testNamePattern
	});
	if (config.testLocationInResults) await dispatch({ name: "include_test_location_in_result" });
	for (const path$1 of [...config.snapshotSerializers].reverse()) addSerializer(localRequire(path$1));
	const snapshotResolver = await buildSnapshotResolver(config, localRequire);
	const snapshotPath = snapshotResolver.resolveSnapshotPath(testPath);
	const snapshotState = new SnapshotState(snapshotPath, {
		expand: globalConfig.expand,
		prettierPath: config.prettierPath,
		rootDir: config.rootDir,
		snapshotFormat: config.snapshotFormat,
		updateSnapshot: globalConfig.updateSnapshot
	});
	jestExpect.setState({
		snapshotState,
		testPath
	});
	addEventHandler(handleSnapshotStateAfterRetry(snapshotState));
	if (sendMessageToJest) addEventHandler(testCaseReportHandler_default(testPath, sendMessageToJest));
	addEventHandler(unhandledRejectionHandler(runtime, globalConfig.waitForUnhandledRejections));
	return {
		globals: globalsObject,
		snapshotState
	};
};
const runAndTransformResultsToJestFormat = async ({ config, globalConfig, setupAfterEnvPerfStats, testPath }) => {
	const runResult = await run_default();
	let numFailingTests = 0;
	let numPassingTests = 0;
	let numPendingTests = 0;
	let numTodoTests = 0;
	const assertionResults = runResult.testResults.map((testResult) => {
		let status;
		if (testResult.status === "skip") {
			status = "pending";
			numPendingTests += 1;
		} else if (testResult.status === "todo") {
			status = "todo";
			numTodoTests += 1;
		} else if (testResult.errors.length > 0) {
			status = "failed";
			numFailingTests += 1;
		} else {
			status = "passed";
			numPassingTests += 1;
		}
		const ancestorTitles = testResult.testPath.filter((name) => name !== ROOT_DESCRIBE_BLOCK_NAME);
		const title = ancestorTitles.pop();
		return {
			ancestorTitles,
			duration: testResult.duration,
			failing: testResult.failing,
			failureDetails: testResult.errorsDetailed,
			failureMessages: testResult.errors,
			fullName: title ? [...ancestorTitles, title].join(" ") : ancestorTitles.join(" "),
			invocations: testResult.invocations,
			location: testResult.location,
			numPassingAsserts: testResult.numPassingAsserts,
			retryReasons: testResult.retryReasons,
			startAt: testResult.startedAt,
			status,
			title: testResult.testPath.at(-1)
		};
	});
	let failureMessage = formatResultsErrors(assertionResults, config, globalConfig, testPath);
	let testExecError;
	if (runResult.unhandledErrors.length > 0) {
		testExecError = {
			message: "",
			stack: runResult.unhandledErrors.join("\n")
		};
		failureMessage = `${failureMessage || ""}\n\n${runResult.unhandledErrors.map((err) => formatExecError(err, config, globalConfig)).join("\n")}`;
	}
	await dispatch({ name: "teardown" });
	const emptyTestResult = createEmptyTestResult();
	return {
		...emptyTestResult,
		console: void 0,
		displayName: config.displayName,
		failureMessage,
		numFailingTests,
		numPassingTests,
		numPendingTests,
		numTodoTests,
		perfStats: {
			...emptyTestResult.perfStats,
			...setupAfterEnvPerfStats
		},
		testExecError,
		testFilePath: testPath,
		testResults: assertionResults
	};
};
const handleSnapshotStateAfterRetry = (snapshotState) => (event) => {
	switch (event.name) {
		case "test_retry": snapshotState.clear();
	}
};
const eventHandler = async (event) => {
	switch (event.name) {
		case "test_start": {
			jestExpect.setState({
				currentTestName: getTestID(event.test),
				testFailing: event.test.failing
			});
			break;
		}
		case "test_done": {
			event.test.numPassingAsserts = jestExpect.getState().numPassingAsserts;
			_addSuppressedErrors(event.test);
			_addExpectedAssertionErrors(event.test);
			break;
		}
	}
};
const _addExpectedAssertionErrors = (test$1) => {
	const { isExpectingAssertions } = jestExpect.getState();
	const failures = jestExpect.extractExpectedAssertionsErrors();
	if (isExpectingAssertions && test$1.errors.length > 0) return;
	test$1.errors.push(...failures.map((failure) => failure.error));
};
const _addSuppressedErrors = (test$1) => {
	const { suppressedErrors } = jestExpect.getState();
	jestExpect.setState({ suppressedErrors: [] });
	if (suppressedErrors.length > 0) test$1.errors.push(...suppressedErrors);
};

//#endregion
export { eventHandler, initialize, runAndTransformResultsToJestFormat };