import { SnapshotResolver } from "jest-snapshot";
import { IHasteFS } from "jest-haste-map";
import Resolver, { ResolveModuleConfig } from "jest-resolve";

//#region src/index.d.ts

type ResolvedModule = {
  file: string;
  dependencies: Array<string>;
};
/**
 * DependencyResolver is used to resolve the direct dependencies of a module or
 * to retrieve a list of all transitive inverse dependencies.
 */
declare class DependencyResolver {
  private readonly _hasteFS;
  private readonly _resolver;
  private readonly _snapshotResolver;
  constructor(resolver: Resolver, hasteFS: IHasteFS, snapshotResolver: SnapshotResolver);
  resolve(file: string, options?: ResolveModuleConfig): Array<string>;
  resolveInverseModuleMap(paths: Set<string>, filter: (file: string) => boolean, options?: ResolveModuleConfig): Array<ResolvedModule>;
  resolveInverse(paths: Set<string>, filter: (file: string) => boolean, options?: ResolveModuleConfig): Array<string>;
}
//#endregion
export { DependencyResolver, ResolvedModule };