export default {
  getMergeRequest: state => (projectID, mergeRequestIID) =>
    (state[projectID] && state[projectID][mergeRequestIID]) || {},
};
