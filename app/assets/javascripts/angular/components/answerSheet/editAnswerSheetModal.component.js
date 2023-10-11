import template from './editAnswerSheetModal.html';

import './editAnswerSheetModal.scss';

angular.module('campusContactsApp').component('editAnswerSheetModal', {
  bindings: {
    resolve: '<',
    dismiss: '&',
    close: '&',
  },
  template,
  controller: editAnswerSheetModalController,
});

function editAnswerSheetModalController(httpProxy, modelsService) {
  this.save = async () => {
    const answers = this.resolve.answerSheet.answers;

    const includedAnswers = answers.map((a) => {
      return {
        type: 'answer',
        attributes: {
          question_id: a.question.id,
          value: a.value,
        },
      };
    });

    const url = modelsService.getModelMetadata('answer_sheet').url.single(this.resolve.answerSheet.id);

    await httpProxy.put(
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
