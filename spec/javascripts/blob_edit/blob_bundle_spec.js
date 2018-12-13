import blobBundle from '~/blob_edit/blob_bundle';
import $ from 'jquery';

describe('BlobBundle', () => {
  beforeEach(() => {
    spyOnDependency(blobBundle, 'EditBlob').and.stub();
    setFixtures(`
      <div class="js-edit-blob-form" data-blob-filename="blah">
        <button class="js-commit-button"></button>
      </div>`);
    blobBundle();
  });

  it('sets the window beforeunload listener to a function returning a string', () => {
    expect(window.onbeforeunload()).toBe('');
  });

  it('removes beforeunload listener if commit button is clicked', () => {
    $('.js-commit-button').click();

    expect(window.onbeforeunload).toBeNull();
  });
});
