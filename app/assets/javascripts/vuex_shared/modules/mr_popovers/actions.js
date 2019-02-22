import Api from '~/api';
import * as mutationTypes from './mutation_types';

// eslint-disable-next-line import/prefer-default-export
export const fetchMergeRequestData = ({ state, commit }, { projectID, mergeRequestIID }) => {
  const dataExists = Boolean(state[projectID] && state[projectID][mergeRequestIID]);

  if (!dataExists) {
    commit(mutationTypes.FETCH_MR_DATA_BEGIN, { projectID, mergeRequestIID });

    Api.projectMergeRequest(projectID, mergeRequestIID)
      .then(({ data }) => {
        commit(mutationTypes.FETCH_MR_DATA_SUCCESS, { projectID, mergeRequestIID, data });
      })
      .catch(error => {
        commit(mutationTypes.FETCH_MR_DATA_ERROR, { projectID, mergeRequestIID, error });
      });
  }
};
