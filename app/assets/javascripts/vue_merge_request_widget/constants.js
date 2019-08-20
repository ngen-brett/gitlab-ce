export const WARNING = 'warning';
export const DANGER = 'danger';

export const WARNING_MESSAGE_CLASS = 'warning_message';
export const DANGER_MESSAGE_CLASS = 'danger_message';

export const MWPS_MERGE_STRATEGY = 'merge_when_pipeline_succeeds';
export const ATMTWPS_MERGE_STRATEGY = 'add_to_merge_train_when_pipeline_succeeds';
export const MT_MERGE_STRATEGY = 'merge_train';

export const AUTO_MERGE_STRATEGIES = [
  MWPS_MERGE_STRATEGY,
  ATMTWPS_MERGE_STRATEGY,
  MT_MERGE_STRATEGY,
];

/** A pipeline whose git ref is a branch */
export const BRANCH_PIPELINE = 'branch_pipeline';
/** A pipeline whose git ref is a tag */
export const TAG_PIPELINE = 'tag_pipeline';
/** A merge request pipeline whose git ref is the source branch */
export const DETACHED_MERGE_REQUEST_PIPELINE = 'detached_merge_request_pipeline';
/** A merge request pipeline whose git ref is the merged result of source branch + target branch */
export const MERGED_RESULT_PIPELINE = 'merged_result_pipeline';
/** A pipeline that is part of a merge train */
export const MERGE_TRAIN_PIPELINE = 'merge_train_pipeline';
/** A pipeline that doesn't fit into any of the categories above */
export const OTHER_PIPELINE = 'other_pipeline';
