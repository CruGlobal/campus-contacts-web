import React from 'react';
import { useTranslation } from 'react-i18next';

import Card from '../../components/Card';
import Header from '../../components/Header';
import MemberStagesChart from '../MemberStagesChart';
import PersonalStepsAddedChart from '../PersonalStepsAddedChart';
import PersonalStepsCompletedChart from '../PersonalStepsCompletedChart';

const PersonalStepsPage = () => {
    const { t } = useTranslation('insights');

    return (
        <div>
            <Header>
                Together we have taken 1,234 personal steps of faith in 2019.
            </Header>
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
                <MemberStagesChart />
            </Card>
            <Card
                title={t('memberStageChanges')}
                subtitle={t('memberStageChangesSubtitle')}
            />
        </div>
    );
};

export default PersonalStepsPage;

PersonalStepsPage.propTypes = {};
