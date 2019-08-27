import Vuex from 'vuex';
import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Clientside from '~/ide/components/preview/clientside.vue';

jest.mock('smooshpack', () => ({
  Manager: jest.fn(),
}));

const localVue = createLocalVue();
localVue.use(Vuex);

const dummyPackageJson = {
  raw: JSON.stringify({
    main: 'index.js',
  }),
};

describe('IDE clientside preview', () => {
  let wrapper;
  let store;

  const createComponent = ({ state, getters } = {}) => {
    store = new Vuex.Store({
      state: {
        entries: {},
        links: {},
        ...state,
      },
      getters: {
        packageJson: () => '',
        currentProject: () => ({
          visibility: 'public',
        }),
        ...getters,
      },
      actions: {
        getFileData: jest.fn().mockReturnValue(Promise.resolve({})),
        getRawFileData: jest.fn().mockReturnValue(Promise.resolve('')),
      },
    });

    wrapper = shallowMount(Clientside, {
      sync: false,
      store,
      localVue,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('without main entry', () => {
    it('creates sandpack manager', () => {
      createComponent();
      jest.spyOn(wrapper.vm, 'initManager');
      expect(wrapper.vm.initManager).not.toHaveBeenCalled();
    });
  });
  describe('with main entry', () => {
    beforeEach(() => {
      createComponent({ getters: { packageJson: () => dummyPackageJson } });

      jest.spyOn(wrapper.vm, 'initManager');
      return wrapper.vm.initPreview();
    });

    it('creates sandpack manager', () => {
      expect(wrapper.vm.initManager).toHaveBeenCalledWith(
        '#ide-preview',
        {
          files: {},
          entry: '/index.js',
          showOpenInCodeSandbox: true,
        },
        {
          fileResolver: {
            isFile: expect.any(Function),
            readFile: expect.any(Function),
          },
        },
      );
    });
  });

  describe('computed', () => {
    describe('normalizedEntries', () => {
      beforeEach(() => {
        createComponent({
          state: {
            entries: {
              'index.js': { type: 'blob', raw: 'test' },
              'index2.js': { type: 'blob', content: 'content' },
              tree: { type: 'tree' },
              empty: { type: 'blob' },
            },
          },
        });
      });

      it('returns flattened list of blobs with content', () => {
        expect(wrapper.vm.normalizedEntries).toEqual({
          '/index.js': {
            code: 'test',
          },
          '/index2.js': {
            code: 'content',
          },
        });
      });
    });

    describe('mainEntry', () => {
      it('returns false when package.json is empty', () => {
        createComponent();
        expect(wrapper.vm.mainEntry).toBe(false);
      });

      it('returns main key from package.json', () => {
        createComponent({ getters: { packageJson: () => dummyPackageJson } });
        expect(wrapper.vm.mainEntry).toBe('index.js');
      });
    });

    describe('showPreview', () => {
      it('returns false if no mainEntry', () => {
        createComponent();
        expect(wrapper.vm.showPreview).toBe(false);
      });

      it('returns false if loading', () => {
        createComponent({ getters: { packageJson: () => dummyPackageJson } });
        wrapper.setData({ loading: true });

        expect(wrapper.vm.showPreview).toBe(false);
      });

      it('returns true if not loading and mainEntry exists', () => {
        createComponent({ getters: { packageJson: () => dummyPackageJson } });
        wrapper.setData({ loading: false });

        expect(wrapper.vm.showPreview).toBe(true);
      });
    });

    describe('showEmptyState', () => {
      it('returns true if no mainEntry exists', () => {
        createComponent();
        wrapper.setData({ loading: false });
        expect(wrapper.vm.showEmptyState).toBe(true);
      });

      it('returns false if loading', () => {
        createComponent({ getters: { packageJson: () => dummyPackageJson } });
        wrapper.setData({ loading: true });

        expect(wrapper.vm.showEmptyState).toBe(false);
      });

      it('returns false if not loading and mainEntry exists', () => {
        createComponent({ getters: { packageJson: () => dummyPackageJson } });
        wrapper.setData({ loading: false });

        expect(wrapper.vm.showEmptyState).toBe(false);
      });
    });

    describe('showOpenInCodeSandbox', () => {
      it('returns true when visiblity is public', () => {
        createComponent({ getters: { currentProject: () => ({ visibility: 'public' }) } });

        expect(wrapper.vm.showOpenInCodeSandbox).toBe(true);
      });

      it('returns false when visiblity is private', () => {
        createComponent({ getters: { currentProject: () => ({ visibility: 'private' }) } });

        expect(wrapper.vm.showOpenInCodeSandbox).toBe(false);
      });
    });

    describe('sandboxOpts', () => {
      beforeEach(() => {
        createComponent({
          state: {
            entries: {
              'index.js': { type: 'blob', raw: 'test' },
              'package.json': dummyPackageJson,
            },
          },
          getters: {
            packageJson: () => dummyPackageJson,
          },
        });
      });

      it('returns sandbox options', () => {
        expect(wrapper.vm.sandboxOpts).toEqual({
          files: {
            '/index.js': {
              code: 'test',
            },
            '/package.json': {
              code: '{"main":"index.js"}',
            },
          },
          entry: '/index.js',
          showOpenInCodeSandbox: true,
        });
      });
    });
  });

  describe('methods', () => {
    describe('loadFileContent', () => {
      beforeEach(() => {
        createComponent();
        jest.spyOn(wrapper.vm, 'getFileData');
        jest.spyOn(wrapper.vm, 'getRawFileData');

        return wrapper.vm.loadFileContent('package.json');
      });

      it('calls getFileData', () => {
        expect(wrapper.vm.getFileData).toHaveBeenCalledWith({
          path: 'package.json',
          makeFileActive: false,
        });
      });

      it('calls getRawFileData', () => {
        expect(wrapper.vm.getRawFileData).toHaveBeenCalledWith({ path: 'package.json' });
      });
    });

    describe('update', () => {
      beforeEach(() => {
        jest.useFakeTimers();
        createComponent();
        wrapper.setData({ sandpackReady: true });
        jest.spyOn(wrapper.vm, 'initPreview');
      });

      it('calls initPreview if manager is empty', () => {
        wrapper.setData({ manager: {} });
        wrapper.vm.update();

        jest.advanceTimersByTime(250);
        expect(wrapper.vm.initPreview).toHaveBeenCalled();
      });

      it('calls updatePreview', () => {
        wrapper.setData({
          manager: {
            listener: jest.fn(),
            updatePreview: jest.fn(),
          },
        });
        wrapper.vm.update();

        jest.advanceTimersByTime(250);
        expect(wrapper.vm.manager.updatePreview).toHaveBeenCalledWith(wrapper.vm.sandboxOpts);
      });
    });
  });

  describe('template', () => {
    it('renders ide-preview element when showPreview is true', () => {
      createComponent({ getters: { packageJson: () => dummyPackageJson } });
      wrapper.setData({ loading: false });

      return wrapper.vm.$nextTick(() => {
        expect(wrapper.find('#ide-preview').exists()).toBe(true);
      });
    });

    it('renders empty state', () => {
      createComponent();
      wrapper.setData({ loading: false });

      return wrapper.vm.$nextTick(() => {
        expect(wrapper.text()).toContain(
          'Preview your web application using Web IDE client-side evaluation.',
        );
      });
    });

    it('renders loading icon', () => {
      createComponent();
      wrapper.setData({ loading: true });

      return wrapper.vm.$nextTick(() => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
      });
    });
  });
});
