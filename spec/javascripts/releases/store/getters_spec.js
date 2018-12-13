import * as getters from '~/releases/store/getters';
import state from '~/releases/store/state';

describe('RELEASES Store Getters', () => {
  let localState;

  beforeEach(() => {
    localState = state();
  });

  describe('description', () => {
    it('description', () => {
      localState.foo = 'foo';

      expect(getters.getter1(localState)).toEqual('foo')
    });
  });
  