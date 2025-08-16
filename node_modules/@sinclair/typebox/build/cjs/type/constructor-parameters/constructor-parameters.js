"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.ConstructorParameters = ConstructorParameters;
const index_1 = require("../tuple/index");
const index_2 = require("../never/index");
const KindGuard = require("../guard/kind");
/** `[JavaScript]` Extracts the ConstructorParameters from the given Constructor type */
function ConstructorParameters(schema, options) {
    return (KindGuard.IsConstructor(schema) ? (0, index_1.Tuple)(schema.parameters, options) : (0, index_2.Never)(options));
}
