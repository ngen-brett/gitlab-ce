import { APPLICATION_STATUS } from '../constants';

const {
  NO_STATUS,
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
        effects: {
          installFailed: true,
        },
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
          updateFailed: true,
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
        effects: {
          installFailed: false,
        },
      },
      // This is possible in artificial environments for E2E testing
      [INSTALLED]: {
        target: INSTALLED,
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
        effects: {
          installFailed: true,
        },
      },
    },
  },
  [INSTALLED]: {
    on: {
      update: {
        target: UPDATING,
        effects: {
          updateFailed: false,
          updateSuccessful: false,
        },
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

/**
 * Determines an application new state based on the application current state
 * and an event. If the application current state cannot handle a given event,
 * the current state is returned.
 *
 * @param {*} application
 * @param {*} event
 */
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
