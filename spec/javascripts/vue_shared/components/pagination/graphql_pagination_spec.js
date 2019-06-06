import { shallowMount } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import GraphqlPagination from '~/vue_shared/components/pagination/graphql_pagination.vue';

fdescribe('Graphql Pagination component', () => {
  let wrapper;
  function factory({ hasNextPage = true, hasPreviousPage = true }) {
    wrapper = shallowMount(GraphqlPagination, {
      propsData: {
        hasNextPage,
        hasPreviousPage,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('without next page', () => {
    beforeEach(() => {
      factory({ hasNextPage: false });
    });
    it('renders disabled next button', () => {
      console.log(wrapper.find(GlButton).attrs())
     // expect(wrapper.find(GlButton).attrs(''))
    });
  });

  describe('with next page', () => {
    it('renders enabled next button', () => {});
    it('emits nextClicked on click', () => {});
  });

  describe('without previous page', () => {
    it('renders disabled previous button', () => {});
  });

  describe('with previous page', () => {
    it('renders enabled previous button', () => {});
    it('emits previousClicked on click', () => {});
  });
});
