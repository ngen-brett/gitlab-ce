import Vue from 'vue';
import { mount, shallowMount } from '@vue/test-utils';
import CustomStageForm from '~/cycle_analytics/components/custom_stage_form.vue';
import data from './cycle_analytics.json';

const { events } = data;
const startEvents = events.filter(ev => ev.can_be_start_event);
const stopEvents = events.filter(ev => !ev.can_be_start_event);

describe('CustomStageForm', () => {
  function createComponent(props, shallow = true) {
    const func = shallow ? shallowMount : mount;
    return func(CustomStageForm, {
      propsData: {
        events,
        ...props,
      },
      sync: false, // fixes '$listeners is readonly' errors
    });
  }

  let wrapper = null;

  const sel = {
    name: '[name="add-stage-name"]',
    startEvent: '[name="add-stage-start-event"]',
    stopEvent: '[name="add-stage-stop-event"]',
    submit: '.js-add-stage',
  };

  describe('Empty form', () => {
    beforeEach(() => {
      wrapper = createComponent({}, false);
    });

    describe.each([
      ['Name', sel.name, true],
      ['Start event', sel.startEvent, true],
      ['Stop event', sel.stopEvent, false],
      ['Submit', sel.submit, false],
    ])('by default', (field, $sel, enabledState) => {
      const state = enabledState ? 'enabled' : 'disabled';
      it(`field '${field}' is ${state}`, () => {
        const el = wrapper.find($sel);
        expect(el.exists()).toBe(true);
        if (!enabledState) {
          expect(el.attributes('disabled')).toBe('disabled');
        } else {
          expect(el.attributes('disabled')).toBeUndefined();
        }
      });
    });

    describe('Start event', () => {
      describe('with events', () => {
        beforeEach(() => {
          wrapper = createComponent({}, false);
        });
        it('selects events with can_be_start_event=true for the start events dropdown', () => {
          const select = wrapper.find(sel.startEvent);
          startEvents.forEach(ev => {
            expect(select.html()).toHaveHtml(
              `<option value="${ev.identifier}">${ev.name}</option>`,
            );
          });
          stopEvents.forEach(ev => {
            expect(select.html()).not.toHaveHtml(
              `<option value="${ev.identifier}">${ev.name}</option>`,
            );
          });
        });

        it('will exclude stop events for the dropdown', () => {
          const select = wrapper.find(sel.startEvent);
          stopEvents.forEach(ev => {
            expect(select.html()).not.toHaveHtml(
              `<option value="${ev.identifier}">${ev.name}</option>`,
            );
          });
        });
      });

      describe.skip('start event label', () => {
        it('is hidden by default', () => {});
        it('will display the start event label field if a label event is selected', () => {});
      });
    });
    describe('Stop event', () => {
      beforeEach(() => {
        wrapper = createComponent(
          {
            events: [
              {
                name: 'Issue created',
                identifier: 'issue_created',
                type: 'simple',
                can_be_start_event: true,
                allowed_end_events: ['issue_closed', 'issue_merged'],
              },
              {
                name: 'Merge request closed',
                identifier: 'merge_request_closed',
                type: 'simple',
                can_be_start_event: false,
                allowed_end_events: [],
              },
              {
                name: 'Issue closed',
                identifier: 'issue_closed',
                type: 'simple',
                can_be_start_event: false,
                allowed_end_events: [],
              },
              {
                name: 'Issue merged',
                identifier: 'issue_merged',
                type: 'simple',
                can_be_start_event: false,
                allowed_end_events: [],
              },
            ],
          },
          false,
        );
      });

      it('is enabled when a start event is selected', () => {
        const el = wrapper.find(sel.stopEvent);
        expect(el.attributes('disabled')).toBe('disabled');
        const opts = wrapper.find(sel.startEvent).findAll('option');
        opts.at(1).setSelected();
        Vue.nextTick(() => expect(el.attributes('disabled')).toBeUndefined());
      });
      it('will update the list of stop events when a start event is changed', () => {
        let stopOptions = wrapper.find(sel.stopEvent).findAll('option');
        expect(stopOptions.length).toBe(1);
        wrapper
          .find(sel.startEvent)
          .findAll('option')
          .at(1)
          .setSelected();
        Vue.nextTick(() => {
          stopOptions = wrapper.find(sel.stopEvent).findAll('option');
          expect(stopOptions.length).toBe(3);
        });
      });

      it('will only display valid stop events allowed for the selected start event', () => {
        let stopOptions = wrapper.find(sel.stopEvent).findAll('option');
        expect(stopOptions.at(0).html()).toEqual('<option value="">Select stop event</option>');
        wrapper
          .find(sel.startEvent)
          .findAll('option')
          .at(1)
          .setSelected();
        Vue.nextTick(() => {
          stopOptions = wrapper.find(sel.stopEvent).findAll('option');
          [
            { name: 'Select stop event', identifier: '' },
            { name: 'Issue closed', identifier: 'issue_closed' },
            { name: 'Issue merged', identifier: 'issue_merged' },
          ].forEach(({ name, identifier }, i) => {
            expect(stopOptions.at(i).html()).toEqual(
              `<option value="${identifier}">${name}</option>`,
            );
          });

          [
            { name: 'Issue created', identifier: 'issue_created' },
            { name: 'Merge request closed', identifier: 'merge_request_closed' },
          ].forEach(({ name, identifier }) => {
            expect(wrapper.find(sel.stopEvent).html()).not.toHaveHtml(
              `<option value="${identifier}">${name}</option>`,
            );
          });
        });
      });

      describe.skip('Stop event label', () => {
        it('is hidden by default', () => {});
        it('will display the stop event label field if a label event is selected', () => {});
      });
    });
    describe.skip('Add stage button', () => {
      it('is enabled when all required fields are filled', () => {});
      it('emits a `submit` event when clicked', () => {
        const btn = wrapper.find(sel.submit);
        expect(wrapper.emitted().submit).toBeUndefined();
        btn.trigger('click');
        expect(wrapper.emitted().submit).toBeTruthy();
        expect(wrapper.emitted().submit.length).toBe(1);
      });
    });
  });
  describe.skip('Prepopulated form', () => {
    describe('Add stage button', () => {
      it('is disabled by default', () => {});
      it('is enabled when a field is changed and fields are valid', () => {});
      it('emits a `submit` event when clicked', () => {});
    });
  });
});
