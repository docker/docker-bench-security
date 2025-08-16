import { createRequire } from "node:module";
import { createHash } from "crypto";
import * as path from "path";
import * as fs from "graceful-fs";
import { requireOrImportModule } from "jest-util";

//#region rolldown:runtime
var __require = /* @__PURE__ */ createRequire(import.meta.url);

//#endregion
//#region src/blacklist.ts
/**
* Copyright (c) Meta Platforms, Inc. and affiliates.
*
* This source code is licensed under the MIT license found in the
* LICENSE file in the root directory of this source tree.
*/
const extensions = new Set([
	".json",
	".bmp",
	".gif",
	".ico",
	".jpeg",
	".jpg",
	".png",
	".svg",
	".tiff",
	".tif",
	".webp",
	".avi",
	".mp4",
	".mpeg",
	".mpg",
	".ogv",
	".webm",
	".3gp",
	".3g2",
	".aac",
	".midi",
	".mid",
	".mp3",
	".oga",
	".wav",
	".3gp",
	".3g2",
	".eot",
	".otf",
	".ttf",
	".woff",
	".woff2"
]);
var blacklist_default = extensions;

//#endregion
//#region src/constants.ts
const constants = {
	DEPENDENCY_DELIM: "\0",
	ID: 0,
	MTIME: 1,
	SIZE: 2,
	VISITED: 3,
	DEPENDENCIES: 4,
	SHA1: 5,
	PATH: 0,
	TYPE: 1,
	MODULE: 0,
	PACKAGE: 1,
	GENERIC_PLATFORM: "g",
	NATIVE_PLATFORM: "native"
};
var constants_default = constants;

//#endregion
//#region src/lib/dependencyExtractor.ts
const NOT_A_DOT = "(?<!\\.\\s*)";
const CAPTURE_STRING_LITERAL = (pos) => `([\`'"])([^'"\`]*?)(?:\\${pos})`;
const WORD_SEPARATOR = "\\b";
const LEFT_PARENTHESIS = "\\(";
const RIGHT_PARENTHESIS = "\\)";
const WHITESPACE = "\\s*";
const OPTIONAL_COMMA = "(:?,\\s*)?";
function createRegExp(parts, flags) {
	return new RegExp(parts.join(""), flags);
}
function alternatives(...parts) {
	return `(?:${parts.join("|")})`;
}
function functionCallStart(...names) {
	return [
		NOT_A_DOT,
		WORD_SEPARATOR,
		alternatives(...names),
		WHITESPACE,
		LEFT_PARENTHESIS,
		WHITESPACE
	];
}
const BLOCK_COMMENT_RE = /\/\*[^]*?\*\//g;
const LINE_COMMENT_RE = /\/\/.*/g;
const REQUIRE_OR_DYNAMIC_IMPORT_RE = createRegExp([
	...functionCallStart("require", "import"),
	CAPTURE_STRING_LITERAL(1),
	WHITESPACE,
	OPTIONAL_COMMA,
	RIGHT_PARENTHESIS
], "g");
const IMPORT_OR_EXPORT_RE = createRegExp(["\\b(?:import|export)\\s+(?!type(?:of)?\\s+)(?:[^'\"]+\\s+from\\s+)?", CAPTURE_STRING_LITERAL(1)], "g");
const JEST_EXTENSIONS_RE = createRegExp([
	...functionCallStart("jest\\s*\\.\\s*(?:requireActual|requireMock|createMockFromModule)"),
	CAPTURE_STRING_LITERAL(1),
	WHITESPACE,
	OPTIONAL_COMMA,
	RIGHT_PARENTHESIS
], "g");
const extractor = { extract(code) {
	const dependencies = /* @__PURE__ */ new Set();
	const addDependency = (match, _, dep) => {
		dependencies.add(dep);
		return match;
	};
	code.replaceAll(BLOCK_COMMENT_RE, "").replaceAll(LINE_COMMENT_RE, "").replace(IMPORT_OR_EXPORT_RE, addDependency).replace(REQUIRE_OR_DYNAMIC_IMPORT_RE, addDependency).replace(JEST_EXTENSIONS_RE, addDependency);
	return dependencies;
} };

//#endregion
//#region src/worker.ts
const PACKAGE_JSON = `${path.sep}package.json`;
function sha1hex(content) {
	return createHash("sha1").update(content).digest("hex");
}
async function worker(data) {
	const hasteImpl = data.hasteImplModulePath ? __require(data.hasteImplModulePath) : null;
	let content;
	let dependencies;
	let id;
	let module;
	let sha1;
	const { computeDependencies, computeSha1, rootDir, filePath } = data;
	const getContent = () => {
		if (content === void 0) content = fs.readFileSync(filePath, "utf8");
		return content;
	};
	if (filePath.endsWith(PACKAGE_JSON)) try {
		const fileData = JSON.parse(getContent());
		if (fileData.name) {
			const relativeFilePath = path.relative(rootDir, filePath);
			id = fileData.name;
			module = [relativeFilePath, constants_default.PACKAGE];
		}
	} catch (error) {
		throw new Error(`Cannot parse ${filePath} as JSON: ${error.message}`);
	}
	else if (!blacklist_default.has(filePath.slice(filePath.lastIndexOf(".")))) {
		if (hasteImpl) id = hasteImpl.getHasteName(filePath);
		if (computeDependencies) {
			const content$1 = getContent();
			const extractor$1 = data.dependencyExtractor ? await requireOrImportModule(data.dependencyExtractor, false) : extractor;
			dependencies = [...extractor$1.extract(content$1, filePath, extractor.extract)];
		}
		if (id) {
			const relativeFilePath = path.relative(rootDir, filePath);
			module = [relativeFilePath, constants_default.MODULE];
		}
	}
	if (computeSha1) sha1 = sha1hex(content || fs.readFileSync(filePath));
	return {
		dependencies,
		id,
		module,
		sha1
	};
}
async function getSha1(data) {
	const sha1 = data.computeSha1 ? sha1hex(fs.readFileSync(data.filePath)) : null;
	return {
		dependencies: void 0,
		id: void 0,
		module: void 0,
		sha1
	};
}

//#endregion
export { getSha1, worker };