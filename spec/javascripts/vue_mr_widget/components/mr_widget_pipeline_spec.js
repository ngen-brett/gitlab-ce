import Vue from 'vue';
import pipelineComponent from '~/vue_merge_request_widget/components/mr_widget_pipeline.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { trimText } from 'spec/helpers/text_helper';
import mockData from '../mock_data';
import {
  BRANCH_PIPELINE,
  DETACHED_MERGE_REQUEST_PIPELINE,
  TAG_PIPELINE,
  OTHER_PIPELINE,
} from '~/vue_merge_request_widget/constants';

describe('MRWidgetPipeline', () => {
  let vm;
  let Component;

  beforeEach(() => {
    Component = Vue.extend(pipelineComponent);
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('computed', () => {
    describe('hasPipeline', () => {
      it('should return true when there is a pipeline', () => {
        vm = mountComponent(Component, {
          pipeline: mockData.pipeline,
          ciStatus: 'success',
          hasCi: true,
          troubleshootingDocsPath: 'help',
        });

        expect(vm.hasPipeline).toEqual(true);
      });

      it('should return false when there is no pipeline', () => {
        vm = mountComponent(Component, {
          pipeline: {},
          troubleshootingDocsPath: 'help',
        });

        expect(vm.hasPipeline).toEqual(false);
      });
    });

    describe('hasCIError', () => {
      it('should return false when there is no CI error', () => {
        vm = mountComponent(Component, {
          pipeline: mockData.pipeline,
          hasCi: true,
          ciStatus: 'success',
          troubleshootingDocsPath: 'help',
        });

        expect(vm.hasCIError).toEqual(false);
      });

      it('should return true when there is a CI error', () => {
        vm = mountComponent(Component, {
          pipeline: mockData.pipeline,
          hasCi: true,
          ciStatus: null,
          troubleshootingDocsPath: 'help',
        });

        expect(vm.hasCIError).toEqual(true);
      });
    });

    describe('when the pipeline is a detached merge request pipeline', () => {
      beforeEach(() => {
        vm = mountComponent(Component, {
          pipeline: {
            ...mockData.pipeline,
            flags: {
              detached_merge_request_pipeline: true,
            },
          },
          hasCi: true,
          troubleshootingDocsPath: 'help',
        });
      });

      describe('pipelineType', () => {
        it('should return DETACHED_MERGE_REQUEST_PIPELINE', () => {
          expect(vm.pipelineType).toEqual(DETACHED_MERGE_REQUEST_PIPELINE);
        });
      });

      describe('pipelineTypeLabel', () => {
        it('should return "Detached merge request pipeline"', () => {
          expect(vm.pipelineTypeLabel).toEqual('Detached merge request pipeline');
        });
      });
    });

    describe('when the pipeline is a branch pipeline', () => {
      beforeEach(() => {
        vm = mountComponent(Component, {
          pipeline: {
            ...mockData.pipeline,
            flags: {
              detached_merge_request_pipeline: false,
            },
            ref: {
              branch: true,
            },
          },
          hasCi: true,
          troubleshootingDocsPath: 'help',
        });
      });

      describe('pipelineType', () => {
        it('should return BRANCH_PIPELINE', () => {
          expect(vm.pipelineType).toEqual(BRANCH_PIPELINE);
        });
      });

      describe('pipelineTypeLabel', () => {
        it('should return "Pipeline"', () => {
          expect(vm.pipelineTypeLabel).toEqual('Pipeline');
        });
      });
    });

    describe('when the pipeline is a tag pipeline', () => {
      beforeEach(() => {
        vm = mountComponent(Component, {
          pipeline: {
            ...mockData.pipeline,
            flags: {
              detached_merge_request_pipeline: false,
            },
            ref: {
              tag: true,
            },
          },
          hasCi: true,
          troubleshootingDocsPath: 'help',
        });
      });

      describe('pipelineType', () => {
        it('should return TAG_PIPELINE', () => {
          expect(vm.pipelineType).toEqual(TAG_PIPELINE);
        });
      });

      describe('pipelineTypeLabel', () => {
        it('should return "Pipeline"', () => {
          expect(vm.pipelineTypeLabel).toEqual('Pipeline');
        });
      });
    });

    describe("when the pipeline can't be categorized", () => {
      beforeEach(() => {
        vm = mountComponent(Component, {
          pipeline: {
            ...mockData.pipeline,
            flags: {
              detached_merge_request_pipeline: false,
            },
            ref: {
              tag: false,
              branch: false,
            },
          },
          hasCi: true,
          troubleshootingDocsPath: 'help',
        });
      });

      describe('pipelineType', () => {
        it('should return OTHER_PIPELINE', () => {
          expect(vm.pipelineType).toEqual(OTHER_PIPELINE);
        });
      });

      describe('pipelineTypeLabel', () => {
        it('should return "Pipeline"', () => {
          expect(vm.pipelineTypeLabel).toEqual('Pipeline');
        });
      });
    });
  });

  describe('rendered output', () => {
    it('should render CI error', () => {
      vm = mountComponent(Component, {
        pipeline: mockData.pipeline,
        hasCi: true,
        troubleshootingDocsPath: 'help',
      });

      expect(vm.$el.querySelector('.media-body').textContent.trim()).toContain(
        'Could not retrieve the pipeline status. For troubleshooting steps, read the documentation.',
      );
    });

    it('should render CI error when no pipeline is provided', () => {
      vm = mountComponent(Component, {
        pipeline: {},
        hasCi: true,
        ciStatus: 'success',
        troubleshootingDocsPath: 'help',
      });

      expect(vm.$el.querySelector('.media-body').textContent.trim()).toContain(
        'Could not retrieve the pipeline status. For troubleshooting steps, read the documentation.',
      );
    });

    describe('with a pipeline', () => {
      beforeEach(() => {
        vm = mountComponent(Component, {
          pipeline: mockData.pipeline,
          hasCi: true,
          ciStatus: 'success',
          troubleshootingDocsPath: 'help',
        });
      });

      it('should render pipeline ID', () => {
        expect(vm.$el.querySelector('.pipeline-id').textContent.trim()).toEqual(
          `#${mockData.pipeline.id}`,
        );
      });

      it('should render pipeline status and commit id', () => {
        expect(vm.$el.querySelector('.media-body').textContent.trim()).toContain(
          mockData.pipeline.details.status.label,
        );

        expect(vm.$el.querySelector('.js-commit-link').textContent.trim()).toEqual(
          mockData.pipeline.commit.short_id,
        );

        expect(vm.$el.querySelector('.js-commit-link').getAttribute('href')).toEqual(
          mockData.pipeline.commit.commit_path,
        );
      });

      it('should render pipeline graph', () => {
        expect(vm.$el.querySelector('.mr-widget-pipeline-graph')).toBeDefined();
        expect(vm.$el.querySelectorAll('.stage-container').length).toEqual(
          mockData.pipeline.details.stages.length,
        );
      });

      it('should render coverage information', () => {
        expect(vm.$el.querySelector('.media-body').textContent).toContain(
          `Coverage ${mockData.pipeline.coverage}`,
        );
      });
    });

    describe('without commit path', () => {
      beforeEach(() => {
        const mockCopy = JSON.parse(JSON.stringify(mockData));
        delete mockCopy.pipeline.commit;

        vm = mountComponent(Component, {
          pipeline: mockCopy.pipeline,
          hasCi: true,
          ciStatus: 'success',
          troubleshootingDocsPath: 'help',
        });
      });

      it('should render pipeline ID', () => {
        expect(vm.$el.querySelector('.pipeline-id').textContent.trim()).toEqual(
          `#${mockData.pipeline.id}`,
        );
      });

      it('should render pipeline status', () => {
        expect(vm.$el.querySelector('.media-body').textContent.trim()).toContain(
          mockData.pipeline.details.status.label,
        );

        expect(vm.$el.querySelector('.js-commit-link')).toBeNull();
      });

      it('should render pipeline graph', () => {
        expect(vm.$el.querySelector('.mr-widget-pipeline-graph')).toBeDefined();
        expect(vm.$el.querySelectorAll('.stage-container').length).toEqual(
          mockData.pipeline.details.stages.length,
        );
      });

      it('should render coverage information', () => {
        expect(vm.$el.querySelector('.media-body').textContent).toContain(
          `Coverage ${mockData.pipeline.coverage}`,
        );
      });
    });

    describe('without coverage', () => {
      it('should not render a coverage', () => {
        const mockCopy = JSON.parse(JSON.stringify(mockData));
        delete mockCopy.pipeline.coverage;

        vm = mountComponent(Component, {
          pipeline: mockCopy.pipeline,
          hasCi: true,
          ciStatus: 'success',
          troubleshootingDocsPath: 'help',
        });

        expect(vm.$el.querySelector('.media-body').textContent).not.toContain('Coverage');
      });
    });

    describe('without a pipeline graph', () => {
      it('should not render a pipeline graph', () => {
        const mockCopy = JSON.parse(JSON.stringify(mockData));
        delete mockCopy.pipeline.details.stages;

        vm = mountComponent(Component, {
          pipeline: mockCopy.pipeline,
          hasCi: true,
          ciStatus: 'success',
          troubleshootingDocsPath: 'help',
        });

        expect(vm.$el.querySelector('.js-mini-pipeline-graph')).toEqual(null);
      });
    });

    describe('for each type of pipeline', () => {
      let pipeline;

      beforeEach(() => {
        ({ pipeline } = JSON.parse(JSON.stringify(mockData)));
      });

      const factory = () => {
        vm = mountComponent(Component, {
          pipeline,
          hasCi: true,
          ciStatus: 'success',
          troubleshootingDocsPath: 'help',
          sourceBranchLink: mockData.source_branch_link,
        });
      };

      describe('for a branch pipeline', () => {
        it('renders a pipeline widget that reads "Pipeline <ID> <status> for <SHA> on <branch>"', () => {
          delete pipeline.merge_request;
          pipeline.flags.detached_merge_request_pipeline = false;
          pipeline.ref.branch = true;

          factory();

          const expected = `Pipeline #${pipeline.id} ${pipeline.details.status.label} for ${pipeline.commit.short_id} on ${mockData.source_branch_link}`;
          const actual = trimText(vm.$el.querySelector('.js-pipeline-info-container').innerText);

          expect(actual).toBe(expected);
        });
      });

      describe('for a detached merge request pipeline', () => {
        it('renders a pipeline widget that reads "Detached merge request pipeline <ID> <status> for <SHA>"', () => {
          pipeline.flags.detached_merge_request_pipeline = true;

          factory();

          const expected = `Detached merge request pipeline #${pipeline.id} ${pipeline.details.status.label} for ${pipeline.commit.short_id}`;
          const actual = trimText(vm.$el.querySelector('.js-pipeline-info-container').innerText);

          expect(actual).toBe(expected);
        });
      });
    });
  });
});
