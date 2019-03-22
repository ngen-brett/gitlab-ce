import setupToggleButtons from '~/toggle_buttons';

export default () => {
  const toggleContainer = document.querySelector('.js-lets-encrypt-toggle-container');

  if (toggleContainer) {
    const onToggleButtonClicked = isEnabled => {
      document.querySelector('.js-shown-if-lets-encrypt').style.display = isEnabled ? '' : 'none';
      document.querySelector('.js-hidden-if-lets-encrypt').style.display = isEnabled ? 'none' : '';
    };

    setupToggleButtons(toggleContainer, onToggleButtonClicked);
  }
};
