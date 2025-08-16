"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.Type = exports.JavaScriptTypeBuilder = exports.JsonTypeBuilder = void 0;
// ------------------------------------------------------------------
// JsonTypeBuilder
// ------------------------------------------------------------------
var json_1 = require("./json");
Object.defineProperty(exports, "JsonTypeBuilder", { enumerable: true, get: function () { return json_1.JsonTypeBuilder; } });
// ------------------------------------------------------------------
// JavaScriptTypeBuilder
// ------------------------------------------------------------------
const TypeBuilder = require("./type");
const javascript_1 = require("./javascript");
Object.defineProperty(exports, "JavaScriptTypeBuilder", { enumerable: true, get: function () { return javascript_1.JavaScriptTypeBuilder; } });
/** JavaScript Type Builder with Static Resolution for TypeScript */
const Type = TypeBuilder;
exports.Type = Type;
