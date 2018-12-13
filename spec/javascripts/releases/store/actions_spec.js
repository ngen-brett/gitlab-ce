import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import {
  setEndpoint,
  requestReleases,
  fetchReleases,
  receiveReleasesSuccess,
  receiveReleasesError,
} from '~/releases/store/actions';
import state from '~/releases/store/state';
import * as types from '~/releases/store/mutation_types';
import testAction from 'spec/helpers/vuex_action_helper';

describe('Releases State actions', () => {
  let mockedState;

  beforeEach(() => {
    mockedState = state();
  });

  describe('setEndpoint', () => {
    it('should commit SET_ENDPOINT mutation', done => {
      testAction(
        setEndpoint,
        'endpoint.json',
        mockedState,
        [{ type: types.SET_ENDPOINT, payload: 'endpoint.json' }],
        [],
        done,
      );
    });
  });

  describe('requestReleases', () => {
    it('should commit REQUEST_RELEASES mutation', done => {
      testAction(requestReleases, null, mockedState, [{ type: types.REQUEST_RELEASES }], [], done);
    });
  });

  describe('fetchReleases', () => {
    let mock;

    beforeEach(() => {
      mockedState.endpoint = 'endpoint.json;'
      mock = new MockAdapter(axios);
    });

    afterEach(() => {
      mock.restore();
    });

    describe('success', () => {
      it('dispatches requestReleases and receiveReleasesSuccess ', done => {
        mock.onGet('endpoint.json').replyOnce(200, { id: 121212 });

        testAction(
          fetchReleases,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestReleases',
            },
            {
              payload: { id: 121212 },
              type: 'receiveReleasesSuccess',
            },
          ],
          done,
        );
      });
    });

    describe('error', () => {
      beforeEach(() => {
        mock.onGet('endpoint.json').reply(500);
      });

      it('dispatches requestReleases and receiveReleasesError ', done => {
        testAction(
          fetchReleases,
          null,
          mockedState,
          [],
          [
            {
              type: 'requestReleases',
            },
            {
              type: 'receiveReleasesError',
            },
          ],
          done,
        );
      });
    });
  });

  describe('receiveReleasesSuccess', () => {
    it('should commit RECEIVE_RELEASES_SUCCESS mutation', done => {
      testAction(
        receiveReleasesSuccess,
        { id: 121232132 },
        mockedState,
        [{ type: types.RECEIVE_RELEASES_SUCCESS, payload: { id: 121232132 } }],
        [],
        done,
      );
    });
  });

  describe('receiveReleasesError', () => {
    it('should commit RECEIVE_RELEASES_ERROR mutation', done => {
      testAction(receiveReleasesError, null, mockedState, [{ type: types.RECEIVE_RELEASES_ERROR }], [], done);
    });
  });
});
  