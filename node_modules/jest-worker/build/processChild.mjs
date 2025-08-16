import { createRequire } from "node:module";
import { types } from "node:util";
import { isPromise } from "jest-util";
import { serialize } from "@ungap/structured-clone";

//#region rolldown:runtime
var __require = /* @__PURE__ */ createRequire(import.meta.url);

//#endregion
//#region src/types.ts
const CHILD_MESSAGE_INITIALIZE = 0;
const CHILD_MESSAGE_CALL = 1;
const CHILD_MESSAGE_END = 2;
const CHILD_MESSAGE_MEM_USAGE = 3;
const CHILD_MESSAGE_CALL_SETUP = 4;
const PARENT_MESSAGE_OK = 0;
const PARENT_MESSAGE_CLIENT_ERROR = 1;
const PARENT_MESSAGE_SETUP_ERROR = 2;
const PARENT_MESSAGE_MEM_USAGE = 4;

//#endregion
//#region src/workers/safeMessageTransferring.ts
function packMessage(message) {
	return {
		__STRUCTURED_CLONE_SERIALIZED__: true,
		data: serialize(message, { json: true })
	};
}

//#endregion
//#region src/workers/processChild.ts
let file = null;
let setupArgs = [];
let initialized = false;
/**
* This file is a small bootstrapper for workers. It sets up the communication
* between the worker and the parent process, interpreting parent messages and
* sending results back.
*
* The file loaded will be lazily initialized the first time any of the workers
* is called. This is done for optimal performance: if the farm is initialized,
* but no call is made to it, child Node processes will be consuming the least
* possible amount of memory.
*
* If an invalid message is detected, the child will exit (by throwing) with a
* non-zero exit code.
*/
const messageListener = (request) => {
	switch (request[0]) {
		case CHILD_MESSAGE_INITIALIZE:
			const init = request;
			file = init[2];
			setupArgs = init[3];
			break;
		case CHILD_MESSAGE_CALL:
			const call = request;
			execMethod(call[2], call[3]);
			break;
		case CHILD_MESSAGE_END:
			end();
			break;
		case CHILD_MESSAGE_MEM_USAGE:
			reportMemoryUsage();
			break;
		case CHILD_MESSAGE_CALL_SETUP:
			if (initialized) reportSuccess(void 0);
			else {
				const main = __require(file);
				initialized = true;
				if (main.setup) execFunction(main.setup, main, setupArgs, reportSuccess, reportInitializeError);
				else reportSuccess(void 0);
			}
			break;
		default: throw new TypeError(`Unexpected request from parent process: ${request[0]}`);
	}
};
process.on("message", messageListener);
function reportSuccess(result) {
	if (!process || !process.send) throw new Error("Child can only be used on a forked process");
	try {
		process.send([PARENT_MESSAGE_OK, result]);
	} catch (error) {
		if (types.isNativeError(error) && !error.message.includes(".send is not a function")) process.send([PARENT_MESSAGE_OK, packMessage(result)]);
		else throw error;
	}
}
function reportClientError(error) {
	return reportError(error, PARENT_MESSAGE_CLIENT_ERROR);
}
function reportInitializeError(error) {
	return reportError(error, PARENT_MESSAGE_SETUP_ERROR);
}
function reportMemoryUsage() {
	if (!process || !process.send) throw new Error("Child can only be used on a forked process");
	const msg = [PARENT_MESSAGE_MEM_USAGE, process.memoryUsage().heapUsed];
	process.send(msg);
}
function reportError(error, type) {
	if (!process || !process.send) throw new Error("Child can only be used on a forked process");
	if (error == null) error = new Error("\"null\" or \"undefined\" thrown");
	process.send([
		type,
		error.constructor && error.constructor.name,
		error.message,
		error.stack,
		typeof error === "object" ? { ...error } : error
	]);
}
function end() {
	const main = __require(file);
	if (!main.teardown) {
		exitProcess();
		return;
	}
	execFunction(main.teardown, main, [], exitProcess, exitProcess);
}
function exitProcess() {
	process.removeListener("message", messageListener);
}
function execMethod(method, args) {
	const main = __require(file);
	let fn;
	if (method === "default") fn = main.__esModule ? main.default : main;
	else fn = main[method];
	function execHelper() {
		execFunction(fn, main, args, reportSuccess, reportClientError);
	}
	if (initialized || !main.setup) {
		execHelper();
		return;
	}
	initialized = true;
	execFunction(main.setup, main, setupArgs, execHelper, reportInitializeError);
}
function execFunction(fn, ctx, args, onResult, onError) {
	let result;
	try {
		result = fn.apply(ctx, args);
	} catch (error) {
		onError(error);
		return;
	}
	if (isPromise(result)) result.then(onResult, onError);
	else onResult(result);
}

//#endregion