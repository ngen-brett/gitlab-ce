import Vue from 'vue';
import * as mutationTypes from './mutation_types';

export default {
  [mutationTypes.FETCH_MR_DATA_BEGIN](state, { projectID, mergeRequestIID }) {
    if (!state[projectID]) {
      Vue.set(state, projectID, {});
    }

    if (!state[projectID][mergeRequestIID]) {
      Vue.set(state[projectID], mergeRequestIID, {});
    }

    state[projectID][mergeRequestIID] = {
      loading: true,
      error: null,
      data: null,
    };
  },
  [mutationTypes.FETCH_MR_DATA_SUCCESS](state, { projectID, mergeRequestIID, data }) {
    state[projectID][mergeRequestIID] = {
      loading: false,
      error: null,
      data,
    };
  },
  [mutationTypes.FETCH_MR_DATA_ERROR](state, { projectID, mergeRequestIID, error }) {
    state[projectID][mergeRequestIID] = {
      loading: false,
      error,
      data: null,
    };
  },
};
