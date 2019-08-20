import {
  BRANCH_PIPELINE,
  TAG_PIPELINE,
  DETACHED_MERGE_REQUEST_PIPELINE,
  OTHER_PIPELINE,
} from '../constants';
import { s__ } from '~/locale';

export default {
  computed: {
    triggered() {
      return [];
    },
    triggeredBy() {
      return [];
    },
    pipelineType() {
      if (this.pipeline.flags.detached_merge_request_pipeline) {
        return DETACHED_MERGE_REQUEST_PIPELINE;
      } else if (this.pipeline.ref.branch) {
        return BRANCH_PIPELINE;
      } else if (this.pipeline.ref.tag) {
        return TAG_PIPELINE;
      }

      return OTHER_PIPELINE;
    },
    pipelineTypeLabel() {
      if (this.pipelineType === DETACHED_MERGE_REQUEST_PIPELINE) {
        return s__('Pipeline|Detached merge request pipeline');
      }

      return s__('Pipeline|Pipeline');
    },
  },
  methods: {
    hasDownstream() {
      return false;
    },
  },
};
