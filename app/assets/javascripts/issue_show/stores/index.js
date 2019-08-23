import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

const DETAILS_OPEN = '<details open>';
const DETAILS_EL_REGEXP = new RegExp(/<details>/, 'g');
const DETAILS_TAG = '<details>';

export default class Store {
  constructor(initialState) {
    this.state = initialState;
    this.formState = {
      title: '',
      description: '',
      lockedWarningVisible: false,
      updateLoading: false,
      lock_version: 0,
    };
  }

  updateState(data) {
    if (this.stateShouldUpdate(data)) {
      this.formState.lockedWarningVisible = true;
    }

    Object.assign(this.state, convertObjectPropsToCamelCase(data));
    // find if there is an open details node inside of the issue description.
    const descriptionSection = $('.detail-page-description.content-block')
    const atLeastOneDetailOpen = descriptionSection.find('details[open]').length > 0;
  
    if (atLeastOneDetailOpen) {
      const details = descriptionSection.find('details');
      let index = 0;

      this.state.descriptionHtml = data.description.replace(DETAILS_EL_REGEXP, () => {
        const shouldReplace = details[index] && details[index].open;
        let str = DETAILS_TAG;

        if(shouldReplace) {
          str =  DETAILS_OPEN;
        }
        
        index += 1;
        return str;
      });
    } else {
      this.state.descriptionHtml = data.description;
    }
    
    this.state.titleHtml = data.title;
    this.state.lock_version = data.lock_version;
  }

  stateShouldUpdate(data) {
    return (
      this.state.titleText !== data.title_text ||
      this.state.descriptionText !== data.description_text
    );
  }

  setFormState(state) {
    this.formState = Object.assign(this.formState, state);
  }
}
