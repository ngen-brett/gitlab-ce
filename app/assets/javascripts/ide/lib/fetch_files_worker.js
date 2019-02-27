import { decorateFiles } from './files_decorator';

// eslint-disable-next-line no-restricted-globals
self.addEventListener('message', e => {
  const { csrf, projectUrl, projectId, branchId } = e.data;

  fetch(`${projectUrl}/files/${branchId}`, {
    headers: {
      [csrf.headerKey]: csrf.token,
    },
  })
    .then(x => (x.ok ? x : Promise.reject(x)))
    .then(x => x.json())
    .then(data =>
      decorateFiles({
        data,
        projectId,
        branchId,
      }),
    )
    .then(data => {
      // eslint-disable-next-line no-restricted-globals
      self.postMessage(data);
    })
    .catch(({ status }) => {
      // eslint-disable-next-line no-restricted-globals
      self.postMessage({
        error: {
          response: {
            status,
          },
        },
      });
    });
});
