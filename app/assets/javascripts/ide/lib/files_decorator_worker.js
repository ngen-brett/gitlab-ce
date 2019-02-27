import { decorateFiles } from './files_decorator';

// eslint-disable-next-line no-restricted-globals
self.addEventListener('message', e => {
  const result = decorateFiles(e.data);

  // eslint-disable-next-line no-restricted-globals
  self.postMessage(result);
});
