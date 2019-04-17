import transitionApplicationState from '~/clusters/services/application_state_machine';
import { APPLICATION_STATUS } from '~/clusters/constants';

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

describe('applicationStateMachine', () => {
  describe(`current state is ${NO_STATUS}`, () => {
    it.each`
      expectedState      | event              | effects
      ${INSTALLING}      | ${SCHEDULED}       | ${{}}
      ${NOT_INSTALLABLE} | ${NOT_INSTALLABLE} | ${{}}
      ${INSTALLABLE}     | ${INSTALLABLE}     | ${{}}
      ${INSTALLING}      | ${INSTALLING}      | ${{}}
      ${INSTALLED}       | ${INSTALLED}       | ${{}}
      ${INSTALLABLE}     | ${ERROR}           | ${{ installFailed: true }}
      ${UPDATING}        | ${UPDATING}        | ${{}}
      ${INSTALLED}       | ${UPDATED}         | ${{}}
      ${INSTALLED}       | ${UPDATE_ERRORED}  | ${{ updateFailed: true }}
    `(`transitions to $expectedState on $event event and applies $effects effects`, data => {
      const { expectedState, event, effects } = data;
      const currentAppState = {
        status: NO_STATUS,
      };

      expect(transitionApplicationState(currentAppState, event)).toEqual({
        status: expectedState,
        ...effects,
      });
    });
  });

  describe(`current state is ${NOT_INSTALLABLE}`, () => {
    it.each`
      expectedState  | event          | effects
      ${INSTALLABLE} | ${INSTALLABLE} | ${{}}
    `(`transitions to $expectedState on $event event and applies $effects effects`, data => {
      const { expectedState, event, effects } = data;
      const currentAppState = {
        status: NOT_INSTALLABLE,
      };

      expect(transitionApplicationState(currentAppState, event)).toEqual({
        status: expectedState,
        ...effects,
      });
    });
  });

  describe(`current state is ${INSTALLABLE}`, () => {
    it.each`
      expectedState | event        | effects
      ${INSTALLING} | ${'install'} | ${{ installFailed: false }}
      ${INSTALLED}  | ${INSTALLED} | ${{}}
    `(`transitions to $expectedState on $event event and applies $effects effects`, data => {
      const { expectedState, event, effects } = data;
      const currentAppState = {
        status: INSTALLABLE,
      };

      expect(transitionApplicationState(currentAppState, event)).toEqual({
        status: expectedState,
        ...effects,
      });
    });
  });

  describe(`current state is ${INSTALLING}`, () => {
    it.each`
      expectedState  | event        | effects
      ${INSTALLED}   | ${INSTALLED} | ${{}}
      ${INSTALLABLE} | ${ERROR}     | ${{ installFailed: true }}
    `(`transitions to $expectedState on $event event and applies $effects effects`, data => {
      const { expectedState, event, effects } = data;
      const currentAppState = {
        status: INSTALLING,
      };

      expect(transitionApplicationState(currentAppState, event)).toEqual({
        status: expectedState,
        ...effects,
      });
    });
  });

  describe(`current state is ${INSTALLED}`, () => {
    it.each`
      expectedState | event       | effects
      ${UPDATING}   | ${'update'} | ${{ updateFailed: false, updateSuccessful: false }}
    `(`transitions to $expectedState on $event event and applies $effects effects`, data => {
      const { expectedState, event, effects } = data;
      const currentAppState = {
        status: INSTALLED,
      };

      expect(transitionApplicationState(currentAppState, event)).toEqual({
        status: expectedState,
        ...effects,
      });
    });
  });

  describe(`current state is ${UPDATING}`, () => {
    it.each`
      expectedState | event             | effects
      ${INSTALLED}  | ${UPDATED}        | ${{ updateSuccessful: true, updateAcknowledged: false }}
      ${INSTALLED}  | ${UPDATE_ERRORED} | ${{ updateFailed: true }}
    `(`transitions to $expectedState on $event event and applies $effects effects`, data => {
      const { expectedState, event, effects } = data;
      const currentAppState = {
        status: UPDATING,
      };

      expect(transitionApplicationState(currentAppState, event)).toEqual({
        status: expectedState,
        ...effects,
      });
    });
  });
});
