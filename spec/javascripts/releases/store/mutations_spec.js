import state from '~/releases/store/state';
import mutations from '~/releases/store/mutations';
import * as types from '~/releases/store/mutation_types';

describe('Releases Store Mutations', () => {
  let stateCopy;

  beforeEach(() => {
    stateCopy = state();
  });

  describe('SET_ENDPOINT', () => {
    it('should set endpoint', () => {
      mutations[types.SET_ENDPOINT](stateCopy, 'endpoint.json');

      expect(stateCopy.endpoint).toEqual('endpoint.json');
    });
  });

  describe('REQUEST_RELEASES', () => {
    it('sets isLoading to true', () => {
      mutations[types.REQUEST_RELEASES](stateCopy);

      expect(stateCopy.isLoading).toEqual(true);
    });
  });

  describe('RECEIVE_RELEASES_SUCCESS', () => {
    it('sets is loading to false', () => {
      mutations[types.RECEIVE_RELEASES_SUCCESS](stateCopy, { id: 1312321 });

      expect(stateCopy.isLoading).toEqual(false);
    });

    it('sets hasError to false', () => {
      mutations[types.RECEIVE_RELEASES_SUCCESS](stateCopy, { id: 1312321 });

      expect(stateCopy.hasError).toEqual(false);
    });

    it('sets data', () => {
      mutations[types.RECEIVE_RELEASES_SUCCESS](stateCopy, { id: 1312321 });

      expect(stateCopy.data).toEqual({ id: 1312321 });
    });
  });

  describe('RECEIVE_RELEASES_ERROR', () => {
    it('resets data', () => {
      mutations[types.RECEIVE_RELEASES_ERROR](stateCopy);

      expect(stateCopy.isLoading).toEqual(false);
      expect(stateCopy.data).toEqual({});
    });
  });
});
  