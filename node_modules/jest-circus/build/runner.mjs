import { createRequire } from "node:module";
import { deepCyclicCopy } from "jest-util";

//#region rolldown:runtime
var __require = /* @__PURE__ */ createRequire(import.meta.url);

//#endregion
//#region src/legacy-code-todo-rewrite/jestAdapter.ts
const FRAMEWORK_INITIALIZER = __require.resolve("./jestAdapterInit");
const jestAdapter = async (globalConfig, config, environment, runtime, testPath, sendMessageToJest) => {
	const { initialize, runAndTransformResultsToJestFormat } = runtime.requireInternalModule(FRAMEWORK_INITIALIZER);
	const { globals, snapshotState } = await initialize({
		config,
		environment,
		globalConfig,
		localRequire: runtime.requireModule.bind(runtime),
		parentProcess: process,
		runtime,
		sendMessageToJest,
		setGlobalsForRuntime: runtime.setGlobalsForRuntime.bind(runtime),
		testPath
	});
	if (config.fakeTimers.enableGlobally) if (config.fakeTimers.legacyFakeTimers) environment.fakeTimers.useFakeTimers();
	else environment.fakeTimersModern.useFakeTimers();
	globals.beforeEach(() => {
		if (config.resetModules) runtime.resetModules();
		if (config.clearMocks) runtime.clearAllMocks();
		if (config.resetMocks) {
			runtime.resetAllMocks();
			if (config.fakeTimers.enableGlobally && config.fakeTimers.legacyFakeTimers) environment.fakeTimers.useFakeTimers();
		}
		if (config.restoreMocks) runtime.restoreAllMocks();
	});
	const setupAfterEnvStart = Date.now();
	for (const path of config.setupFilesAfterEnv) {
		const esm$1 = runtime.unstable_shouldLoadAsEsm(path);
		if (esm$1) await runtime.unstable_importModule(path);
		else {
			const setupFile = runtime.requireModule(path);
			if (typeof setupFile === "function") await setupFile();
		}
	}
	const setupAfterEnvEnd = Date.now();
	const esm = runtime.unstable_shouldLoadAsEsm(testPath);
	if (esm) await runtime.unstable_importModule(testPath);
	else runtime.requireModule(testPath);
	const setupAfterEnvPerfStats = {
		setupAfterEnvEnd,
		setupAfterEnvStart
	};
	const results = await runAndTransformResultsToJestFormat({
		config,
		globalConfig,
		setupAfterEnvPerfStats,
		testPath
	});
	_addSnapshotData(results, snapshotState);
	return deepCyclicCopy(results, { keepPrototype: false });
};
const _addSnapshotData = (results, snapshotState) => {
	for (const { fullName, status: status$1, failing } of results.testResults) if (status$1 === "pending" || status$1 === "failed" || failing && status$1 === "passed") snapshotState.markSnapshotsAsCheckedForTest(fullName);
	const uncheckedCount = snapshotState.getUncheckedCount();
	const uncheckedKeys = snapshotState.getUncheckedKeys();
	if (uncheckedCount) snapshotState.removeUncheckedKeys();
	const status = snapshotState.save();
	results.snapshot.fileDeleted = status.deleted;
	results.snapshot.added = snapshotState.added;
	results.snapshot.matched = snapshotState.matched;
	results.snapshot.unmatched = snapshotState.unmatched;
	results.snapshot.updated = snapshotState.updated;
	results.snapshot.unchecked = status.deleted ? 0 : uncheckedCount;
	results.snapshot.uncheckedKeys = [...uncheckedKeys];
};
var jestAdapter_default = jestAdapter;

//#endregion
//#region src/runner.ts
var runner_default = jestAdapter_default;

//#endregion
export { runner_default as default };