import template from './editAnswerSheetModal.html';

import './editAnswerSheetModal.scss';

angular.module('missionhubApp').component('editAnswerSheetModal', {
    bindings: {
        resolve: '<',
        dismiss: '&',
        close: '&',
    },
    template: template,
    controller: editAnswerSheetModalController,
});

function editAnswerSheetModalController(httpProxy, modelsService) {
    this.save = async answerId => {
        this.resolve.answerSheet.answers.forEach(async a => {
            let { data } = await httpProxy.put(
                modelsService
                    .getModelMetadata('answer_sheet')
                    .url.single(this.resolve.answerSheet.id),
                {
                    data: {
                        type: 'answer_sheet',
                        attributes: {},
                    },
                    included: [
                        {
                            type: 'answer',
                            attributes: {
                                question_id: a.question.id,
                                value: a.value,
                            },
                        },
                    ],
                },
                {
                    errorMessage: 'surveyTab:errors.updateSurvey',
                },
            );
        });

        this.dismiss();
    };

    this.onInit;
}
