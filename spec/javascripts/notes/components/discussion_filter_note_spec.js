import Vue from 'vue';
import DiscussionFilterNote from '~/notes/components/discussion_filter_note.vue';

import mountComponent from '../../helpers/vue_mount_component_helper';

describe('DiscussionFilterNote component', () => {
  let vm;

  const createComponent = () => {
    const Component = Vue.extend(DiscussionFilterNote);

    return mountComponent(Component);
  };

  beforeEach(() => {
    window.mrTabs = undefined;
    vm = createComponent();
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('renders component container element with classes `timeline-entry note note-wrapper discussion-filter-note js-discussion-filter-note`', () => {
    const expectedClasses = [
      'timeline-entry',
      'note',
      'note-wrapper',
      'discussion-filter-note',
      'js-discussion-filter-note',
    ];

    expectedClasses.forEach(className => {
      expect(vm.$el.classList.contains(className)).toBe(true);
    });
  });

  it('renders comment icon element', () => {
    expect(vm.$el.querySelector('.timeline-icon svg use').getAttribute('xlink:href')).toContain(
      'comment',
    );
  });

  it('renders filter information note', () => {
    expect(vm.$el.querySelector('.timeline-content').innerText.trim()).toContain(
      "You're only seeing other activity in the feed. To add a comment, switch to one of the following options.",
    );
  });

  it('renders filter buttons', () => {
    const buttonsContainerEl = vm.$el.querySelector('.discussion-filter-actions');

    expect(buttonsContainerEl.querySelector('button:first-child').innerText.trim()).toContain(
      'Show all activity',
    );

    expect(buttonsContainerEl.querySelector('button:last-child').innerText.trim()).toContain(
      'Show comments only',
    );
  });
});
