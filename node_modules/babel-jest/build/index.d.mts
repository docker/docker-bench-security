import { TransformOptions } from "@babel/core";
import { SyncTransformer, TransformerCreator } from "@jest/transform";

//#region src/index.d.ts

interface TransformerConfig extends TransformOptions {
  excludeJestPreset?: boolean;
}
declare const createTransformer: TransformerCreator<SyncTransformer<TransformerConfig>, TransformerConfig>;
declare const transformerFactory: {
  createTransformer: TransformerCreator<SyncTransformer<TransformerConfig>, TransformerConfig>;
};
//#endregion
export { createTransformer, transformerFactory as default };