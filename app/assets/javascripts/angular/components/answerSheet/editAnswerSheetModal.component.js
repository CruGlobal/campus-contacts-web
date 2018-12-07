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
        const answers = this.resolve.answerSheet.answers;

        const includedAnswers = answers.map(a => {
            return {
                type: 'answer',
                attributes: {
                    question_id: a.question.id,
                    value: a.value,
                },
            };
        });

        const url = modelsService
            .getModelMetadata('answer_sheet')
            .url.single(this.resolve.answerSheet.id);

        const { data } = await httpProxy.put(
            url,
            {
                data: {
                    type: 'answer_sheet',
                    attributes: {},
                },
                included: includedAnswers,
            },
            {
                params: { include: 'answers' },
                errorMessage: 'surveyTab:errors.updateSurvey',
            },
        );

        this.close();
    };
}
