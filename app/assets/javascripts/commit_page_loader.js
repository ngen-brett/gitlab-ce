import $ from 'jquery';

import {
  isScrolledToBottom,
} from '~/lib/utils/scroll_utils';
import axios from './lib/utils/axios_utils';

export default class CommitPageLoader {
  constructor(projectPath, commitId) {
    this.currentBatch = 1;
    this.projectPath = projectPath;
    this.commitID = commitId;
  }

  loadNextFilesBatch() {
    $(window).on('scroll', () => {
      if(isScrolledToBottom()){
        this.currentBatch++;
        console.log("nextBatch...");
        console.log(this.currentBatch)
        this.callDiffForPaths(this.currentBatch);
      }
    });
  }

  callDiffForPaths(batchNumber) {
    const url = `/${gon.current_username}/${this.projectPath}/commit/${this.commitID}/diff_for_paths`

    return axios
      .get(url, {
        params: {
          batch_number: batchNumber
        },
      })
      .then(({ data }) => {
        return data;
      });
  }
}
