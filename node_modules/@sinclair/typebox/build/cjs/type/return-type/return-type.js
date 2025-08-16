"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.ReturnType = ReturnType;
const type_1 = require("../create/type");
const index_1 = require("../never/index");
const KindGuard = require("../guard/kind");
/** `[JavaScript]` Extracts the ReturnType from the given Function type */
function ReturnType(schema, options) {
    return (KindGuard.IsFunction(schema) ? (0, type_1.CreateType)(schema.returns, options) : (0, index_1.Never)(options));
}
