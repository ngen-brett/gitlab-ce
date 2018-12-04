import $ from 'jquery';

export default function initImportCSVModal() {
  const $modal = $('.issues-import-modal');
  const $downloadBtn = $('.csv-import-button');
  const $closeBtn = $('.issues-import-modal .modal-header .close');

  $modal.modal({ show: false });
  $downloadBtn.on('click', () => $modal.modal('show'));
  $closeBtn.on('click', () => $modal.modal('hide'));
}
