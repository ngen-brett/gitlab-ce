import { shallowMount } from '@vue/test-utils';
import Line from '~/jobs/components/log/line.vue';
import LineNumber from '~/jobs/components/log/line_number.vue';

describe('Job Log Line', () => {
  const props = {
    line: {
      content: [
        {
          text: 'Running with gitlab-runner 12.1.0 (de7731dd)',
          style: 'term-fg-l-green term-bold',
        },
      ],
      lineNumber: 0,
    },
    path: '/jashkenas/underscore/-/jobs/335',
  };
  const wrapper = shallowMount(Line, props);

  beforeAll(() => {
    wrapper.destroy();
  });

  it('renders the line number component', () => {
    expect(wrapper.contains(LineNumber)).toBe(true);
  });

  it('renders a span the provided text', () => {
    expect(wrapper.contains(props.line.content[0].text)).toBe(true);
  });

  it('renders the provided style as a class attribute', () => {
    expect(wrapper.find('span').classes()).toContain(props.line.content[0].style);
  });
});
