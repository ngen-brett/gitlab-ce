import Api from '../../api';
import Cache from './cache';

class MRCache extends Cache {
  static makeKey(projectID, mergeRequestIID) {
    return `MR-${projectID}-${mergeRequestIID}`;
  }

  retrieve(projectID, mergeRequestIID) {
    const key = MRCache.makeKey(projectID, mergeRequestIID);
    if (this.hasData(key)) {
      console.log({ mr: this.get(key) });
      return Promise.resolve(this.get(key));
    }

    return Api.projectMergeRequest(projectID, mergeRequestIID).then(({ data: mergeRequest }) => {
      this.internalStorage[key] = mergeRequest;
      console.log({ mergeRequest });
      return mergeRequest;
    });
    // missing catch is intentional, error handling depends on use case
  }
}

export default new MRCache();
