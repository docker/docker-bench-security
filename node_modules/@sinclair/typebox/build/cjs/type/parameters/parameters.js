"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.Parameters = Parameters;
const index_1 = require("../tuple/index");
const index_2 = require("../never/index");
const KindGuard = require("../guard/kind");
/** `[JavaScript]` Extracts the Parameters from the given Function type */
function Parameters(schema, options) {
    return (KindGuard.IsFunction(schema) ? (0, index_1.Tuple)(schema.parameters, options) : (0, index_2.Never)());
}
