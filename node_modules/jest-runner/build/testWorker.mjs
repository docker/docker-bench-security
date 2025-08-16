import { createRequire } from "node:module";
import exit from "exit-x";
import HasteMap from "jest-haste-map";
import { formatExecError, separateMessageFromStack } from "jest-message-util";
import Runtime from "jest-runtime";
import { messageParent } from "jest-worker";
import { runInContext } from "node:vm";
import chalk from "chalk";
import * as fs from "graceful-fs";
import * as sourcemapSupport from "source-map-support";
import { BufferedConsole, CustomConsole, NullConsole, getConsoleOutput } from "@jest/console";
import { createScriptTransformer } from "@jest/transform";
import * as docblock from "jest-docblock";
import LeakDetector from "jest-leak-detector";
import { resolveTestEnvironment } from "jest-resolve";
import { ErrorWithStack, interopRequireDefault, setGlobal } from "jest-util";

//#region rolldown:runtime
var __require = /* @__PURE__ */ createRequire(import.meta.url);

//#endregion
//#region src/runTest.ts
function freezeConsole(testConsole, config) {
	testConsole._log = function fakeConsolePush(_type, message) {
		const error = new ErrorWithStack(`${chalk.red(`${chalk.bold("Cannot log after tests are done.")} Did you forget to wait for something async in your test?`)}\nAttempted to log "${message}".`, fakeConsolePush);
		const formattedError = formatExecError(error, config, { noStackTrace: false }, void 0, true);
		process.stderr.write(`\n${formattedError}\n`);
		process.exitCode = 1;
	};
}
async function runTestInternal(path, globalConfig, projectConfig, resolver, context, sendMessageToJest$1) {
	const testSource = fs.readFileSync(path, "utf8");
	const docblockPragmas = docblock.parse(docblock.extract(testSource));
	const customEnvironment = docblockPragmas["jest-environment"];
	const loadTestEnvironmentStart = Date.now();
	let testEnvironment = projectConfig.testEnvironment;
	if (customEnvironment) {
		if (Array.isArray(customEnvironment)) throw new TypeError(`You can only define a single test environment through docblocks, got "${customEnvironment.join(", ")}"`);
		testEnvironment = resolveTestEnvironment({
			...projectConfig,
			requireResolveFunction: (module) => __require.resolve(module),
			testEnvironment: customEnvironment
		});
	}
	const cacheFS = new Map([[path, testSource]]);
	const transformer = await createScriptTransformer(projectConfig, cacheFS);
	const TestEnvironment = await transformer.requireAndTranspileModule(testEnvironment);
	const testFramework = await transformer.requireAndTranspileModule(process.env.JEST_JASMINE === "1" ? __require.resolve("jest-jasmine2") : projectConfig.testRunner);
	const Runtime$1 = interopRequireDefault(projectConfig.runtime ? __require(projectConfig.runtime) : __require("jest-runtime")).default;
	const consoleOut = globalConfig.useStderr ? process.stderr : process.stdout;
	const consoleFormatter = (type, message) => getConsoleOutput(BufferedConsole.write([], type, message, 4), projectConfig, globalConfig);
	let testConsole;
	if (globalConfig.silent) testConsole = new NullConsole(consoleOut, consoleOut, consoleFormatter);
	else if (globalConfig.verbose) testConsole = new CustomConsole(consoleOut, consoleOut, consoleFormatter);
	else testConsole = new BufferedConsole();
	let extraTestEnvironmentOptions;
	const docblockEnvironmentOptions = docblockPragmas["jest-environment-options"];
	if (typeof docblockEnvironmentOptions === "string") extraTestEnvironmentOptions = JSON.parse(docblockEnvironmentOptions);
	const environment = new TestEnvironment({
		globalConfig,
		projectConfig: extraTestEnvironmentOptions ? {
			...projectConfig,
			testEnvironmentOptions: {
				...projectConfig.testEnvironmentOptions,
				...extraTestEnvironmentOptions
			}
		} : projectConfig
	}, {
		console: testConsole,
		docblockPragmas,
		testPath: path
	});
	const loadTestEnvironmentEnd = Date.now();
	if (typeof environment.getVmContext !== "function") {
		console.error(`Test environment found at "${testEnvironment}" does not export a "getVmContext" method, which is mandatory from Jest 27. This method is a replacement for "runScript".`);
		process.exit(1);
	}
	const leakDetector = projectConfig.detectLeaks ? new LeakDetector(environment) : null;
	setGlobal(environment.global, "console", testConsole, "retain");
	const runtime = new Runtime$1(projectConfig, environment, resolver, transformer, cacheFS, {
		changedFiles: context.changedFiles,
		collectCoverage: globalConfig.collectCoverage,
		collectCoverageFrom: globalConfig.collectCoverageFrom,
		coverageProvider: globalConfig.coverageProvider,
		sourcesRelatedToTestsInChangedFiles: context.sourcesRelatedToTestsInChangedFiles
	}, path, globalConfig);
	let isTornDown = false;
	const tearDownEnv = async () => {
		if (!isTornDown) {
			runtime.teardown();
			runInContext("Error.prepareStackTrace = () => '';", environment.getVmContext());
			sourcemapSupport.resetRetrieveHandlers();
			await environment.teardown();
			isTornDown = true;
		}
	};
	const start = Date.now();
	const setupFilesStart = Date.now();
	for (const path$1 of projectConfig.setupFiles) {
		const esm = runtime.unstable_shouldLoadAsEsm(path$1);
		if (esm) await runtime.unstable_importModule(path$1);
		else {
			const setupFile = runtime.requireModule(path$1);
			if (typeof setupFile === "function") await setupFile();
		}
	}
	const setupFilesEnd = Date.now();
	const sourcemapOptions = {
		environment: "node",
		handleUncaughtExceptions: false,
		retrieveSourceMap: (source) => {
			const sourceMapSource = runtime.getSourceMaps()?.get(source);
			if (sourceMapSource) try {
				return {
					map: JSON.parse(fs.readFileSync(sourceMapSource, "utf8")),
					url: source
				};
			} catch {}
			return null;
		}
	};
	runtime.requireInternalModule(__require.resolve("source-map-support")).install(sourcemapOptions);
	sourcemapSupport.install(sourcemapOptions);
	if (environment.global && environment.global.process && environment.global.process.exit) {
		const realExit = environment.global.process.exit;
		environment.global.process.exit = function exit$1(...args) {
			const error = new ErrorWithStack(`process.exit called with "${args.join(", ")}"`, exit$1);
			const formattedError = formatExecError(error, projectConfig, { noStackTrace: false }, void 0, true);
			process.stderr.write(formattedError);
			return realExit(...args);
		};
	}
	const collectV8Coverage = globalConfig.collectCoverage && globalConfig.coverageProvider === "v8" && typeof environment.getVmContext === "function";
	Error.stackTraceLimit = 100;
	try {
		await environment.setup();
		let result;
		try {
			if (collectV8Coverage) await runtime.collectV8Coverage();
			result = await testFramework(globalConfig, projectConfig, environment, runtime, path, sendMessageToJest$1);
		} catch (error) {
			let e = error;
			while (typeof e === "object" && e !== null && "stack" in e) {
				e.stack;
				e = e?.cause;
			}
			throw error;
		} finally {
			if (collectV8Coverage) await runtime.stopCollectingV8Coverage();
		}
		freezeConsole(testConsole, projectConfig);
		const testCount = result.numPassingTests + result.numFailingTests + result.numPendingTests + result.numTodoTests;
		const end = Date.now();
		const testRuntime = end - start;
		result.perfStats = {
			...result.perfStats,
			end,
			loadTestEnvironmentEnd,
			loadTestEnvironmentStart,
			runtime: testRuntime,
			setupFilesEnd,
			setupFilesStart,
			slow: testRuntime / 1e3 > projectConfig.slowTestThreshold,
			start
		};
		result.testFilePath = path;
		result.console = testConsole.getBuffer();
		result.skipped = testCount === result.numPendingTests;
		result.displayName = projectConfig.displayName;
		const coverage = runtime.getAllCoverageInfoCopy();
		if (coverage) {
			const coverageKeys = Object.keys(coverage);
			if (coverageKeys.length > 0) result.coverage = coverage;
		}
		if (collectV8Coverage) {
			const v8Coverage = runtime.getAllV8CoverageInfoCopy();
			if (v8Coverage && v8Coverage.length > 0) result.v8Coverage = v8Coverage;
		}
		if (globalConfig.logHeapUsage) {
			globalThis.gc?.();
			result.memoryUsage = process.memoryUsage().heapUsed;
		}
		await tearDownEnv();
		return await new Promise((resolve) => {
			setImmediate(() => resolve({
				leakDetector,
				result
			}));
		});
	} finally {
		await tearDownEnv();
	}
}
async function runTest(path, globalConfig, config, resolver, context, sendMessageToJest$1) {
	const { leakDetector, result } = await runTestInternal(path, globalConfig, config, resolver, context, sendMessageToJest$1);
	if (leakDetector) {
		await new Promise((resolve) => setTimeout(resolve, 100));
		result.leaks = await leakDetector.isLeaking();
	} else result.leaks = false;
	return result;
}

//#endregion
//#region src/testWorker.ts
process.on("uncaughtException", (err) => {
	if (err.stack) console.error(err.stack);
	else console.error(err);
	exit(1);
});
const formatError = (error) => {
	if (typeof error === "string") {
		const { message, stack } = separateMessageFromStack(error);
		return {
			message,
			stack,
			type: "Error"
		};
	}
	return {
		code: error.code || void 0,
		message: error.message,
		stack: error.stack,
		type: "Error"
	};
};
const resolvers = /* @__PURE__ */ new Map();
const getResolver = (config) => {
	const resolver = resolvers.get(config.id);
	if (!resolver) throw new Error(`Cannot find resolver for: ${config.id}`);
	return resolver;
};
function setup(setupData) {
	for (const { config, serializableModuleMap } of setupData.serializableResolvers) {
		const moduleMap = HasteMap.getStatic(config).getModuleMapFromJSON(serializableModuleMap);
		resolvers.set(config.id, Runtime.createResolver(config, moduleMap));
	}
}
const sendMessageToJest = (eventName, args) => {
	messageParent([eventName, args]);
};
async function worker({ config, globalConfig, path, context }) {
	try {
		return await runTest(path, globalConfig, config, getResolver(config), {
			...context,
			changedFiles: context.changedFiles && new Set(context.changedFiles),
			sourcesRelatedToTestsInChangedFiles: context.sourcesRelatedToTestsInChangedFiles && new Set(context.sourcesRelatedToTestsInChangedFiles)
		}, sendMessageToJest);
	} catch (error) {
		throw formatError(error);
	}
}

//#endregion
export { setup, worker };