import React from 'react';
import { useTranslation } from 'react-i18next';

import Card from '../../components/Card';
import PersonalStepsAddedChart from '../PersonalStepsAddedChart';
import PersonalStepsCompletedChart from '../PersonalStepsCompletedChart';
import PersonalStepsCompletedSummary from '../PersonalStepsCompletedSummary';
import PersonalStepsMemberStagesChart from '../PersonalStepsMemberStagesChart';
import PersonalStepsTakenInfo from '../PersonalStepsTakenInfo';
import PersonalStepsReachedInfo from '../PersonalStepsReachedInfo';

const PersonalStepsPage = () => {
    const { t } = useTranslation('insights');

    return (
        <div>
            <PersonalStepsTakenInfo />
            <Card title={t('personalSteps.completedTotal')}>
                <PersonalStepsCompletedSummary />
            </Card>
            <Card
                title={t('personalSteps.completed')}
                subtitle={t('personalSteps.completedSubtitle')}
            >
                <PersonalStepsCompletedChart />
            </Card>
            <Card
                title={t('personalSteps.added')}
                subtitle={t('personalSteps.addedSubtitle')}
            >
                <PersonalStepsAddedChart />
            </Card>
            <PersonalStepsReachedInfo />
            <Card
                title={t('personalSteps.members')}
                subtitle={t('personalSteps.membersSubtitle')}
            >
                <PersonalStepsMemberStagesChart />
            </Card>
        </div>
    );
};

export default PersonalStepsPage;

PersonalStepsPage.propTypes = {};
