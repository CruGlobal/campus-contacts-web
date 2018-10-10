import template from './organizationOverviewSurveys.html';
import './organizationOverviewSurveys.scss';
import _ from 'lodash';

angular.module('missionhubApp').component('organizationOverviewSurveys', {
    require: {
        organizationOverview: '^',
    },
    template: template,
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
) {
    this.surveyLinkPrefix = envService.is('production')
        ? 'https://mhub.cc/s/'
        : 'https://stage.mhub.cc/s/';

    this.createSurvey = () => {
        $uibModal
            .open({
                component: 'createSurvey',
                resolve: {
                    organizationId: _.constant(
                        this.organizationOverview.org.id,
                    ),
                },
                windowClass: 'pivot_theme',
                size: 'sm',
            })
            .result.then(newSurvey => {
                this.organizationOverview.surveys.push(newSurvey);

                //go to edit screen
                $state.go('app.ministries.ministry.survey.manage', {
                    surveyId: newSurvey.id,
                });
            });
    };

    this.copySurvey = survey => {
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

    this.deleteSurvey = survey => {
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
                    this.organizationOverview.surveys.splice(
                        this.organizationOverview.surveys.indexOf(survey),
                        1,
                    );
                });
            });
    };

    this.massEntry = survey => {
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
}
