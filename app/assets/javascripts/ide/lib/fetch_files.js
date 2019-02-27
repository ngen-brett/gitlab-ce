import FilesFetchWorker from './fetch_files_worker';

const worker = new FilesFetchWorker();

export default message =>
  new Promise((resolve, reject) => {
    worker.addEventListener('message', e => {
      if (e.error) {
        reject(e.error);
      } else {
        resolve(e.data);
      }
    });

    worker.addEventListener('error', e => {
      reject(e);
    });

    worker.postMessage(message);
  });
