import $ from 'jquery';

export default function groupAvatar() {
  $('.js-choose-group-avatar-button').on('click', function onClickGroupAvatar() {
    const form = $(this).closest('form');
    return form.find('.js-group-avatar-input').click();
  });
  $('.js-group-avatar-input').on('change', function onChangeAvatarInput() {
    const form = $(this).closest('form');
    const filename = $(this)
      .val()
      .replace(/^.*[\\\/]/, ''); // eslint-disable-line no-useless-escape
    return form.find('.js-avatar-filename').text(filename);
  });
}
