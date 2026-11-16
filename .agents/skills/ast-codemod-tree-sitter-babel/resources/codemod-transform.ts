import { Transform } from 'jscodeshift';
export const transform: Transform = (fileInfo, api) => {
  const j = api.jscodeshift;
  return j(fileInfo.source).find(j.Identifier, { name: 'oldApi' }).forEach(p => p.replace(j.identifier('newApi'))).toSource();
};
