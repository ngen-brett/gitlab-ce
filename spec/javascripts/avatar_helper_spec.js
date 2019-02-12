import {
  IDENTICON_BG_COUNT,
  getIdenticonBackgroundClass,
  getIdenticonTitle,
} from '~/helpers/avatar_helper';

describe('avatar_helper', () => {
  describe('getIdenticonBackgroundClass', () => {
    it('returns identicon bg class from id', () => {
      expect(getIdenticonBackgroundClass(1)).toEqual('bg2');
    });

    it(`wraps around if id is bigger than ${IDENTICON_BG_COUNT}`, () => {
      expect(getIdenticonBackgroundClass(IDENTICON_BG_COUNT + 4)).toEqual('bg5');
      expect(getIdenticonBackgroundClass(IDENTICON_BG_COUNT * 5 + 6)).toEqual('bg7');
    });
  });

  describe('getIdenticonTitle', () => {
    it('returns identicon title from name', () => {
      expect(getIdenticonTitle('Lorem')).toEqual('L');
      expect(getIdenticonTitle('dolar-sit-amit')).toEqual('D');
      expect(getIdenticonTitle('%-with-special-chars')).toEqual('%');
    });

    it('returns space if name is falsey', () => {
      expect(getIdenticonTitle('')).toEqual(' ');
      expect(getIdenticonTitle(null)).toEqual(' ');
    });
  });
});
