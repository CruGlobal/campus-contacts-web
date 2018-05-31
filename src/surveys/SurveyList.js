import React, {Component} from 'react';
import PropTypes from 'prop-types';
import {react2angular} from 'react2angular';

class SurveyList extends Component {
    render () {
        const { surveys } = this.props;
        return <div className="grid-content">
            {
                surveys.map(survey => <div key={survey.id} className="survey row padded">{survey.title}</div>)
            }
        </div>;
    }
}

SurveyList.propTypes = {
    surveys: PropTypes.array,
};

angular.module('missionhubApp')
    .component('surveyList', react2angular(SurveyList));
