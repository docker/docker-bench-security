import { createRequire } from "node:module";
import { runAsWorker } from "synckit";
import "graceful-fs";
import "@jest/snapshot-utils";
import { plugins } from "pretty-format";

//#region rolldown:runtime
var __require = /* @__PURE__ */ createRequire(import.meta.url);

//#endregion
//#region src/plugins.ts
const { DOMCollection, DOMElement, Immutable, ReactElement, ReactTestComponent, AsymmetricMatcher } = plugins;

//#endregion
//#region src/utils.ts
const indent = (snapshot, numIndents, indentation) => {
	const lines = snapshot.split("\n");
	if (lines.length >= 2 && lines[1].startsWith(indentation.repeat(numIndents + 1))) return snapshot;
	return lines.map((line, index) => {
		if (index === 0) return line;
		else if (index === lines.length - 1) return indentation.repeat(numIndents) + line;
		else {
			if (line === "") return line;
			return indentation.repeat(numIndents + 1) + line;
		}
	}).join("\n");
};
const generate = __require(__require.resolve("@babel/generator", { [Symbol.for("jest-resolve-outside-vm-option")]: true })).default;
const { parseSync, types } = __require(__require.resolve("@babel/core", { [Symbol.for("jest-resolve-outside-vm-option")]: true }));
const { isAwaitExpression, templateElement, templateLiteral, traverseFast, traverse } = types;
const processPrettierAst = (ast, options, snapshotMatcherNames, keepNode) => {
	traverse(ast, (node, ancestors) => {
		if (node.type !== "CallExpression") return;
		const { arguments: args, callee } = node;
		if (callee.type !== "MemberExpression" || callee.property.type !== "Identifier" || !snapshotMatcherNames.includes(callee.property.name) || !callee.loc || callee.computed) return;
		let snapshotIndex;
		let snapshot;
		for (const [i, node$1] of args.entries()) if (node$1.type === "TemplateLiteral") {
			snapshotIndex = i;
			snapshot = node$1.quasis[0].value.raw;
		}
		if (snapshot === void 0) return;
		const parent = ancestors.at(-1).node;
		const startColumn = isAwaitExpression(parent) && parent.loc ? parent.loc.start.column : callee.loc.start.column;
		const useSpaces = !options?.useTabs;
		snapshot = indent(snapshot, Math.ceil(useSpaces ? startColumn / (options?.tabWidth ?? 1) : startColumn / 2), useSpaces ? " ".repeat(options?.tabWidth ?? 1) : "	");
		if (keepNode) args[snapshotIndex].quasis[0].value.raw = snapshot;
		else {
			const replacementNode = templateLiteral([templateElement({ raw: snapshot })], []);
			args[snapshotIndex] = replacementNode;
		}
	});
};
const groupSnapshotsBy = (createKey) => (snapshots) => snapshots.reduce((object, inlineSnapshot) => {
	const key = createKey(inlineSnapshot);
	return {
		...object,
		[key]: [...object[key] || [], inlineSnapshot]
	};
}, {});
const groupSnapshotsByFrame = groupSnapshotsBy(({ frame: { line, column } }) => typeof line === "number" && typeof column === "number" ? `${line}:${column - 1}` : "");
const groupSnapshotsByFile = groupSnapshotsBy(({ frame: { file } }) => file);

//#endregion
//#region src/worker.ts
let prettier;
async function getInferredParser(filepath) {
	const fileInfo = await prettier.getFileInfo(filepath);
	return fileInfo.inferredParser;
}
runAsWorker(async (prettierPath, filepath, sourceFileWithSnapshots, snapshotMatcherNames) => {
	prettier ??= __require(
		/*webpackIgnore: true*/
		__require.resolve(prettierPath, { [Symbol.for("jest-resolve-outside-vm-option")]: true })
	);
	const config = await prettier.resolveConfig(filepath, { editorconfig: true });
	const inferredParser = typeof config?.parser === "string" ? config.parser : await getInferredParser(filepath);
	if (!inferredParser) throw new Error(`Could not infer Prettier parser for file ${filepath}`);
	sourceFileWithSnapshots = await prettier.format(sourceFileWithSnapshots, {
		...config,
		filepath,
		parser: inferredParser
	});
	const { ast } = await prettier.__debug.parse(sourceFileWithSnapshots, {
		...config,
		filepath,
		originalText: sourceFileWithSnapshots,
		parser: inferredParser
	});
	processPrettierAst(ast, config, snapshotMatcherNames, true);
	const formatAST = await prettier.__debug.formatAST(ast, {
		...config,
		filepath,
		originalText: sourceFileWithSnapshots,
		parser: inferredParser
	});
	return formatAST.formatted;
});

//#endregion