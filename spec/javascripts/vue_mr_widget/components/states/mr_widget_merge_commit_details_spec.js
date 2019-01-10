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
        author_name: 'Commit Test Name',
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

  describe('computed', () => {
    describe('author', () => {
      it('should return commit author if present', () => {
        expect(vm.author).toEqual(vm.commit.author);
      });

      it('should return an empty object when no author is present in commit', () => {
        vm.commit.author = null;

        expect(vm.author).toEqual({});
      });
    });

    describe('authorName', () => {
      it('should return author name from author object if present', () => {
        expect(vm.authorName).toEqual(vm.commit.author.name);
      });

      it('should return author name from commit data if no author name present', () => {
        vm.author.name = null;

        expect(vm.authorName).toEqual(vm.commit.author_name);
      });
    });

    describe('authorClass', () => {
      it('should be equal to author name, if present', () => {
        expect(vm.authorClass).toEqual('js-user-link');
      });

      it('should be an empty string if no author name is present', () => {
        vm.author.name = null;

        expect(vm.authorClass).toEqual('');
      });
    });

    describe('authorId', () => {
      it('should be equal to author id, if present', () => {
        expect(vm.authorId).toEqual(vm.commit.author.id);
      });

      it('should be an empty string if no author id is present', () => {
        vm.author.id = null;

        expect(vm.authorId).toEqual('');
      });
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
