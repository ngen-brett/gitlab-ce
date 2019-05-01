import mountErrorTrackingForm from '~/error_tracking_settings';
import mountExternalDashboardForm from '~/external_dashboard_settings';

document.addEventListener('DOMContentLoaded', () => {
  mountErrorTrackingForm();
  mountExternalDashboardForm();
});
