"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.InstanceType = InstanceType;
const type_1 = require("../create/type");
const index_1 = require("../never/index");
const KindGuard = require("../guard/kind");
/** `[JavaScript]` Extracts the InstanceType from the given Constructor type */
function InstanceType(schema, options) {
    return (KindGuard.IsConstructor(schema) ? (0, type_1.CreateType)(schema.returns, options) : (0, index_1.Never)(options));
}
