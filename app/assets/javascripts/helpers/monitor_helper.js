import svgs from '@gitlab/svgs/dist/icons.svg';

export function debounceByAnimationFrame(fn) {
  let requestId;

  return function debounced(...args) {
    if (requestId) {
      window.cancelAnimationFrame(requestId);
    }
    requestId = window.requestAnimationFrame(() => fn.apply(this, args));
  };
}

export function getSvgIconPath(name) {
  return new DOMParser()
    .parseFromString(svgs, 'text/xml')
    .querySelector(`#${name} path`)
    .getAttribute('d');
}
