import $ from 'jquery';
import _ from 'underscore';
import axios from '~/lib/utils/axios_utils';
import flash from '~/flash';
import { __ } from '~/locale';

const hexToRgb = (hex) => {
  // Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
  const shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
  const fullHex = hex.replace(shorthandRegex, (_m, r, g, b) => r + r + g + g + b + b);

  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(fullHex);
  return result ? [
    parseInt(result[1], 16),
    parseInt(result[2], 16),
    parseInt(result[3], 16)
  ] : null;
}

const textColorForBackground = (backgroundColor) => {
  const [r, g, b] = hexToRgb(backgroundColor);

  if (r + g + b > 500) {
    return '#333333';
  }
  return '#FFFFFF';
}

export default () => {
  const $broadcastMessageColor = $('input#broadcast_message_color');
  $('input#broadcast_message_color').on('input', function onMessageColorInput() {
    const previewColor = $(this).val();
    $('div.broadcast-message-preview').css('background-color', previewColor);
  });

  $('input#broadcast_message_font').on('input', function onMessageFontInput() {
    const previewColor = $(this).val();
    $('div.broadcast-message-preview').css('color', previewColor);
  });

  const previewPath = $('textarea#broadcast_message_message').data('previewPath');

  $('textarea#broadcast_message_message').on(
    'input',
    _.debounce(function onMessageInput() {
      const message = $(this).val();
      if (message === '') {
        $('.js-broadcast-message-preview').text(__('Your message here'));
      } else {
        axios
          .post(previewPath, {
            broadcast_message: {
              message,
            },
          })
          .then(({ data }) => {
            $('.js-broadcast-message-preview').html(data.message);
          })
          .catch(() => flash(__('An error occurred while rendering preview broadcast message')));
      }
    }, 250),
  );

  const updateColorPreview = () => {
    const selectedBackgroundColor = $('input#broadcast_message_color').val();
    const contrastTextColor = textColorForBackground(selectedBackgroundColor);

    // save contrastTextColor to hidden input field
    $('input.text-font-color').val(contrastTextColor);

    // Updates the preview color with the hex-color input
    $('.label-color-preview').css('background-color', selectedBackgroundColor).css('color', contrastTextColor);
    return $('div.broadcast-message-preview').css('background-color', selectedBackgroundColor).css('color', contrastTextColor);
  }

  const setSuggestedColor = (e) => {
    const color = $(e.currentTarget).data('color');
    $broadcastMessageColor.val(color)
      // Notify the form, that color has changed
      .trigger('input');
    updateColorPreview();
    return e.preventDefault();
  };

  $(document).on('click', '.suggest-colors a', setSuggestedColor);
};
