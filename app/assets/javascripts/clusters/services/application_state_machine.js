import { APPLICATION_STATUS } from '../constants';

const {
  SCHEDULED,
  NOT_INSTALLABLE,
  INSTALLABLE,
  INSTALLING,
  INSTALLED,
  ERROR,
  UPDATING,
  UPDATED,
  UPDATE_ERRORED,
} = APPLICATION_STATUS;
const NO_STATUS = null;

const applicationStateMachine = {
  [NO_STATUS]: {
    on: {
      [SCHEDULED]: {
        target: INSTALLING,
      },
      [NOT_INSTALLABLE]: {
        target: NOT_INSTALLABLE,
      },
      [INSTALLABLE]: {
        target: INSTALLABLE,
      },
      [INSTALLING]: {
        target: INSTALLING,
      },
      [INSTALLED]: {
        target: INSTALLED,
      },
      [ERROR]: {
        target: INSTALLABLE,
      },
      [UPDATING]: {
        target: UPDATING,
      },
      [UPDATED]: {
        target: INSTALLED,
      },
      [UPDATE_ERRORED]: {
        target: INSTALLED,
        effects: {
          updateFailed: false,
        },
      },
    },
  },
  [NOT_INSTALLABLE]: {
    on: {
      [INSTALLABLE]: {
        target: INSTALLABLE,
      },
    },
  },
  [INSTALLABLE]: {
    on: {
      install: {
        target: INSTALLING,
      },
    },
  },
  [INSTALLING]: {
    on: {
      [INSTALLED]: {
        target: INSTALLED,
      },
      [ERROR]: {
        target: INSTALLABLE,
      },
    },
  },
  [INSTALLED]: {
    on: {
      update: {
        target: UPDATING,
      },
    },
  },
  [UPDATING]: {
    on: {
      [UPDATED]: {
        target: INSTALLED,
        effects: {
          updateSuccessful: true,
          updateAcknowledged: false,
        },
      },
      [UPDATE_ERRORED]: {
        target: INSTALLED,
        effects: {
          updateFailed: true,
        },
      },
    },
  },
};

const transitionApplicationState = (application, event) => {
  const newState = applicationStateMachine[application.status].on[event];

  return newState
    ? {
        ...application,
        status: newState.target,
        ...newState.effects,
      }
    : application;
};

export default transitionApplicationState;
