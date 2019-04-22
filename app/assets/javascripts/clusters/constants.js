// These need to match the enum found in app/models/clusters/cluster.rb
export const CLUSTER_TYPE = {
  INSTANCE: 'instance_type',
  GROUP: 'group_type',
  PROJECT: 'project_type',
};

// These need to match what is returned from the server
export const APPLICATION_STATUS = {
  NO_STATUS: null,
  NOT_INSTALLABLE: 'not_installable',
  INSTALLABLE: 'installable',
  SCHEDULED: 'scheduled',
  INSTALLING: 'installing',
  INSTALLED: 'installed',
  UPDATING: 'updating',
  UPDATED: 'updated',
  UPDATE_ERRORED: 'update_errored',
  UNINSTALLING: 'uninstalling',
  UNINSTALL_ERRORED: 'uninstall_errored',
  ERROR: 'errored',
};

/*
 * The application cannot be in any of the following states without
 * not being installed.
 */
export const APPLICATION_INSTALLED_STATUSES = [
  APPLICATION_STATUS.INSTALLED,
  APPLICATION_STATUS.UPDATING,
  APPLICATION_STATUS.UPDATED,
  APPLICATION_STATUS.UPDATE_ERRORED,
  APPLICATION_STATUS.UNINSTALLING,
  APPLICATION_STATUS.UNINSTALL_ERRORED,
];

// These are only used client-side
export const REQUEST_SUBMITTED = 'request-submitted';
export const REQUEST_FAILURE = 'request-failure';
export const UPGRADE_REQUESTED = 'upgrade-requested';
export const UPGRADE_REQUEST_FAILURE = 'upgrade-request-failure';
export const INGRESS = 'ingress';
export const JUPYTER = 'jupyter';
export const KNATIVE = 'knative';
export const RUNNER = 'runner';
export const CERT_MANAGER = 'cert_manager';
export const PROMETHEUS = 'prometheus';
export const INGRESS_DOMAIN_SUFFIX = '.nip.io';
