import { getFirstCharacterCapitalized } from '~/lib/utils/text_utility';

export const DEFAULT_SIZE_CLASS = 's40';
export const IDENTICON_BG_COUNT = 7;

export function getIdenticonBackgroundClass(entityId) {
  const type = (entityId % IDENTICON_BG_COUNT) + 1;
  return `bg${type}`;
}

export function getIdenticonTitle(entityName) {
  return getFirstCharacterCapitalized(entityName) || ' ';
}
