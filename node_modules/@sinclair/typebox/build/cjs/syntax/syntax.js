"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.NoInfer = NoInfer;
exports.Syntax = Syntax;
const t = require("../type/index");
const parser_1 = require("./parser");
/** `[Experimental]` Parses type expressions into TypeBox types but does not infer */
// prettier-ignore
function NoInfer(...args) {
    const withContext = typeof args[0] === 'string' ? false : true;
    const [context, code, options] = withContext ? [args[0], args[1], args[2] || {}] : [{}, args[0], args[1] || {}];
    const result = (0, parser_1.Type)(code, context)[0];
    return t.KindGuard.IsSchema(result)
        ? t.CloneType(result, options)
        : t.Never(options);
}
/** `[Experimental]` Parses type expressions into TypeBox types */
function Syntax(...args) {
    return NoInfer.apply(null, args);
}
