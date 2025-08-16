"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.Partial = Partial;
const type_1 = require("../create/type");
const index_1 = require("../computed/index");
const index_2 = require("../optional/index");
const index_3 = require("../object/index");
const index_4 = require("../intersect/index");
const index_5 = require("../union/index");
const index_6 = require("../ref/index");
const index_7 = require("../discard/index");
const index_8 = require("../symbols/index");
const partial_from_mapped_result_1 = require("./partial-from-mapped-result");
// ------------------------------------------------------------------
// KindGuard
// ------------------------------------------------------------------
const KindGuard = require("../guard/kind");
// prettier-ignore
function FromComputed(target, parameters) {
    return (0, index_1.Computed)('Partial', [(0, index_1.Computed)(target, parameters)]);
}
// prettier-ignore
function FromRef($ref) {
    return (0, index_1.Computed)('Partial', [(0, index_6.Ref)($ref)]);
}
// prettier-ignore
function FromProperties(properties) {
    const partialProperties = {};
    for (const K of globalThis.Object.getOwnPropertyNames(properties))
        partialProperties[K] = (0, index_2.Optional)(properties[K]);
    return partialProperties;
}
// prettier-ignore
function FromObject(type) {
    const options = (0, index_7.Discard)(type, [index_8.TransformKind, '$id', 'required', 'properties']);
    const properties = FromProperties(type['properties']);
    return (0, index_3.Object)(properties, options);
}
// prettier-ignore
function FromRest(types) {
    return types.map(type => PartialResolve(type));
}
// ------------------------------------------------------------------
// PartialResolve
// ------------------------------------------------------------------
// prettier-ignore
function PartialResolve(type) {
    return (
    // Mappable
    KindGuard.IsComputed(type) ? FromComputed(type.target, type.parameters) :
        KindGuard.IsRef(type) ? FromRef(type.$ref) :
            KindGuard.IsIntersect(type) ? (0, index_4.Intersect)(FromRest(type.allOf)) :
                KindGuard.IsUnion(type) ? (0, index_5.Union)(FromRest(type.anyOf)) :
                    KindGuard.IsObject(type) ? FromObject(type) :
                        // Intrinsic
                        KindGuard.IsBigInt(type) ? type :
                            KindGuard.IsBoolean(type) ? type :
                                KindGuard.IsInteger(type) ? type :
                                    KindGuard.IsLiteral(type) ? type :
                                        KindGuard.IsNull(type) ? type :
                                            KindGuard.IsNumber(type) ? type :
                                                KindGuard.IsString(type) ? type :
                                                    KindGuard.IsSymbol(type) ? type :
                                                        KindGuard.IsUndefined(type) ? type :
                                                            // Passthrough
                                                            (0, index_3.Object)({}));
}
/** `[Json]` Constructs a type where all properties are optional */
function Partial(type, options) {
    if (KindGuard.IsMappedResult(type)) {
        return (0, partial_from_mapped_result_1.PartialFromMappedResult)(type, options);
    }
    else {
        // special: mapping types require overridable options
        return (0, type_1.CreateType)({ ...PartialResolve(type), ...options });
    }
}
