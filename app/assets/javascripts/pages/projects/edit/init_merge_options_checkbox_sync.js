export default () => {
  const mergePipelinesEnabledCheckbox = document.querySelector('#project_merge_pipelines_enabled');
  const mergeTrainsEnabledCheckbox = document.querySelector('#project_merge_trains_enabled');

  const syncMergeOptionsCheckboxes = () => {
    if (mergePipelinesEnabledCheckbox.checked) {
      mergeTrainsEnabledCheckbox.removeAttribute('disabled');
    } else {
      mergeTrainsEnabledCheckbox.setAttribute('disabled', 'disabled');
      mergeTrainsEnabledCheckbox.checked = false;
    }
  };

  if (mergePipelinesEnabledCheckbox && mergeTrainsEnabledCheckbox) {
    mergePipelinesEnabledCheckbox.addEventListener('change', syncMergeOptionsCheckboxes);
    syncMergeOptionsCheckboxes();
  }
};
