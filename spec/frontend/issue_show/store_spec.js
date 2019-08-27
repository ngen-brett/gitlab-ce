import Store from '~/issue_show/stores';
import * as issueUtils from '~/issue_show/utils/issue_description';

describe('Store', () => {
  let store;

  beforeEach(() => {
    store = new Store({
      descriptionHtml: '<p>This is a description</p>',
    });
  });

  describe('updateState', () => {
    beforeEach(() => {
      document.body.innerHTML = `
            <div class="detail-page-description content-block">
              <details open>
                <summary>One</summary>
              </details>
              <details>
                <summary>Two</summary>
              </details>
            </div>
          `;
    });

    it('calls updateDetailsState', () => {
      jest.spyOn(issueUtils, 'updateDetailsState').mockImplementationOnce(() => '');

      store.updateState({ description: '' });

      expect(issueUtils.updateDetailsState).toHaveBeenCalledTimes(1);
    });

    it('returns the correct value to be set as descriptionHtml', () => {
      store.updateState({ description: '<details><summary>One</summary></details><details><summary>Two</summary></details>' });

      expect(store.state.descriptionHtml).toEqual('<details open="true"><summary>One</summary></details><details><summary>Two</summary></details>');
    });

    describe('when description details returned from api is different then whats currently on the dom', () => {
      it('returns the description from the api', () => {
        const dataDescription = '<details><summary>One</summary></details>';

        store.updateState({ description: dataDescription });

        expect(store.state.descriptionHtml).toEqual(dataDescription);
      });
    });
  });
});
