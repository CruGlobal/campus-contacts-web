import './organizationOverviewSurveys.scss';
import _ from 'lodash';

import template from './organizationOverviewSurveys.html';

angular.module('campusContactsApp').component('organizationOverviewSurveys', {
  require: {
    organizationOverview: '^',
  },
  template,
  controller: organizationOverviewSurveysController,
});

function organizationOverviewSurveysController(
  $scope,
  $state,
  $uibModal,
  surveyService,
  confirmModalService,
  envService,
  tFilter,
  loggedInPerson,
) {
  this.surveyLinkPrefix = envService.read('surveyLinkPrefix');

  this.$onInit = () => {
    this.directAdminPrivileges = loggedInPerson.isDirectAdminAt(this.organizationOverview.org);
  };

  this.createSurvey = () => {
    $uibModal
      .open({
        component: 'createSurvey',
        resolve: {
          organizationId: _.constant(this.organizationOverview.org.id),
        },
        windowClass: 'pivot_theme',
        size: 'sm',
      })
      .result.then((newSurvey) => {
        // go to edit screen
        $state.go('app.ministries.ministry.survey.manage', {
          surveyId: newSurvey.id,
        });
      });
  };

  this.copySurvey = (survey) => {
    $uibModal.open({
      component: 'copySurvey',
      resolve: {
        organizationId: _.constant(this.organizationOverview.org.id),
        survey: _.constant(survey),
      },
      windowClass: 'pivot_theme',
      size: 'md',
    });
  };

  this.changeStatus = (survey, active) => {
    survey.is_frozen = !active;
    surveyService.updateSurvey(survey);
  };

  this.deleteSurvey = (survey) => {
    if (!survey) {
      return;
    }

    confirmModalService
      .create(
        tFilter('surveys:delete:confirm', {
          survey_title: survey.title,
        }),
      )
      .then(() => {
        surveyService.deleteSurvey(survey).then(() => {
          this.organizationOverview.surveys.splice(this.organizationOverview.surveys.indexOf(survey), 1);
        });
      });
  };

  this.massEntry = (survey) => {
    $uibModal.open({
      component: 'addSurveyResponseModal',
      resolve: {
        survey: () => survey,
      },
      windowClass: 'pivot_theme',
      backdrop: 'static',
      keyboard: false,
    });
  };
  this.showTypeformModal = () => {
    $uibModal.open({
      component: 'surveyTypeformModal',
      resolve: {
        webhookUrl: () => this.organizationOverview.org.typeform_webhook_url,
      },
      windowClass: 'pivot_theme',
    });
  };
}
