import Vue from 'vue';
import mergeCommitDetailsComponent from '~/vue_merge_request_widget/components/states/merge_commit_details.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';

describe('MRWidgetMergeCommitDetails', () => {
  let vm;
  beforeEach(() => {
    const Component = Vue.extend(mergeCommitDetailsComponent);
    vm = mountComponent(Component, {
      commit: {
        author: {
          avatar_url:
            'https://www.gravatar.com/avatar/79e8be0c27f341afc67c0ab9f9030d17?s=72&amp;d=identicon',
          id: '12345',
          name: 'Test Name',
        },
        author_email: 'test@gitlab.com',
        authored_date: '2018-12-05',
        description_html: 'Test description!',
      },
    });
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('data', () => {
    it('should have default data', () => {
      expect(vm.showCommitMessageEditor).toBeFalsy();
      expect(vm.showCommitDescription).toBeFalsy();
    });
  });

  it('should toggle showCommitMessageEditor flag', () => {
    expect(vm.showCommitMessageEditor).toBeFalsy();
    vm.toggleCommitMessageEditor();

    expect(vm.showCommitMessageEditor).toBeTruthy();
  });

  it('should toggle showCommitDescription flag', () => {
    expect(vm.showCommitDescription).toBeFalsy();
    vm.toggleCommitDescription();

    expect(vm.showCommitDescription).toBeTruthy();
  });
});
