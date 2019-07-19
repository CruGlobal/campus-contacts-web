import React from 'react';
import { useTranslation } from 'react-i18next';

import Card from '../../components/Card';
import PersonalStepsAddedChart from '../PersonalStepsAddedChart';
import PersonalStepsCompletedChart from '../PersonalStepsCompletedChart';
import PersonalStepsCompletedTotalChart from '../PersonalStepsCompletedTotalChart';
import PersonalStepsMemberStagesChart from '../PersonalStepsMemberStagesChart';
import PersonalStepsTakenInfo from '../PersonalStepsTakenInfo';

const PersonalStepsPage = () => {
    const { t } = useTranslation('insights');

    return (
        <div>
            <PersonalStepsTakenInfo />
            <Card title={t('personalStepsCompletedTotal')}>
                <PersonalStepsCompletedTotalChart />
            </Card>
            <Card
                title={t('personalStepsCompleted')}
                subtitle={t('personalStepsCompletedSubtitle')}
            >
                <PersonalStepsCompletedChart />
            </Card>
            <Card
                title={t('personalStepsAdded')}
                subtitle={t('personalStepsAddedSubtitle')}
            >
                <PersonalStepsAddedChart />
            </Card>
            <Card
                title={t('memberStages')}
                subtitle={t('memberStagesSubtitle')}
            >
                <PersonalStepsMemberStagesChart />
            </Card>
        </div>
    );
};

export default PersonalStepsPage;

PersonalStepsPage.propTypes = {};
