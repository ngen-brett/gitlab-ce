export const confirmDeletionModalState = () => ({
  // Controls modal's visibility
  isVisible: false,

  // Item to be deleted
  item: {},

  // Item title
  title: '',

  // Item type, either repository or image
  type: '',

  // Delete success callback
  onSuccess: () => {},

  // Delete error callback
  onError: () => {},
});

export default () => ({
  isLoading: false,
  endpoint: '', // initial endpoint to fetch the repos list
  /**
   * Each object in `repos` has the following strucure:
   * {
   *   name: String,
   *   isLoading: Boolean,
   *   tagsPath: String // endpoint to request the list
   *   destroyPath: String // endpoit to delete the repo
   *   list: Array // List of the registry images
   * }
   *
   * Each registry image inside `list` has the following structure:
   * {
   *   tag: String,
   *   revision: String
   *   shortRevision: String
   *   size: Number
   *   layers: Number
   *   createdAt: String
   *   destroyPath: String // endpoit to delete each image
   * }
   */
  repos: [],
  confirmDeletionModal: confirmDeletionModalState(),
});
