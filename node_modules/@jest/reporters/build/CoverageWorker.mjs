import exit from "exit-x";
import * as fs$1 from "graceful-fs";
import * as fs from "graceful-fs";
import { createFileCoverage } from "istanbul-lib-coverage";
import { readInitialCoverage } from "istanbul-lib-instrument";
import { createScriptTransformer, shouldInstrument } from "@jest/transform";

//#region src/generateEmptyCoverage.ts
async function generateEmptyCoverage(source, filename, globalConfig, config, changedFiles, sourcesRelatedToTestsInChangedFiles) {
	const coverageOptions = {
		changedFiles,
		collectCoverage: globalConfig.collectCoverage,
		collectCoverageFrom: globalConfig.collectCoverageFrom,
		coverageProvider: globalConfig.coverageProvider,
		sourcesRelatedToTestsInChangedFiles
	};
	let coverageWorkerResult = null;
	if (shouldInstrument(filename, coverageOptions, config)) {
		if (coverageOptions.coverageProvider === "v8") {
			const stat = fs$1.statSync(filename);
			return {
				kind: "V8Coverage",
				result: {
					functions: [{
						functionName: "(empty-report)",
						isBlockCoverage: true,
						ranges: [{
							count: 0,
							endOffset: stat.size,
							startOffset: 0
						}]
					}],
					scriptId: "0",
					url: filename
				}
			};
		}
		const scriptTransformer = await createScriptTransformer(config);
		const { code } = await scriptTransformer.transformSourceAsync(filename, source, {
			instrument: true,
			supportsDynamicImport: true,
			supportsExportNamespaceFrom: true,
			supportsStaticESM: true,
			supportsTopLevelAwait: true
		});
		const extracted = readInitialCoverage(code);
		if (extracted) coverageWorkerResult = {
			coverage: createFileCoverage(extracted.coverageData),
			kind: "BabelCoverage"
		};
	}
	return coverageWorkerResult;
}

//#endregion
//#region src/CoverageWorker.ts
process.on("uncaughtException", (err) => {
	if (err.stack) console.error(err.stack);
	else console.error(err);
	exit(1);
});
function worker({ config, globalConfig, path, context }) {
	return generateEmptyCoverage(fs.readFileSync(path, "utf8"), path, globalConfig, config, context.changedFiles && new Set(context.changedFiles), context.sourcesRelatedToTestsInChangedFiles && new Set(context.sourcesRelatedToTestsInChangedFiles));
}

//#endregion
export { worker };