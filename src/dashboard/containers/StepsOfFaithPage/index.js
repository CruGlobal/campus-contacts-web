import React from 'react';
import { useTranslation } from 'react-i18next';

import Card from '../../components/Card';
import StepsOfFaithAddedChart from '../StepsOfFaithAddedChart';
import StepsOfFaithCompletedChart from '../StepsOfFaithCompletedChart';
import StepsOfFaithCompletedSummary from '../StepsOfFaithCompletedSummary';
import StepsOfFaithTakenInfo from '../StepsOfFaithTakenInfo';
import StepsOfFaithReachedInfo from '../StepsOfFaithReachedInfo';
import StepsOfFaithPeopleChart from '../StepsOfFaithPeopleChart';

const StepsOfFaithPage = () => {
    const { t } = useTranslation('insights');

    return (
        <div>
            <StepsOfFaithTakenInfo />
            <Card title={t('stepsOfFaith.totalCompleted')}>
                <StepsOfFaithCompletedSummary />
            </Card>
            <Card
                title={t('stepsOfFaith.completed')}
                subtitle={t('stepsOfFaith.completedSubtitle')}
            >
                <StepsOfFaithCompletedChart />
            </Card>
            <Card
                title={t('stepsOfFaith.added')}
                subtitle={t('stepsOfFaith.addedSubtitle')}
            >
                <StepsOfFaithAddedChart />
            </Card>
            <StepsOfFaithReachedInfo />
            <Card
                title={t('stepsOfFaith.people')}
                subtitle={t('stepsOfFaith.peopleSubtitle')}
            >
                <StepsOfFaithPeopleChart />
            </Card>
        </div>
    );
};

export default StepsOfFaithPage;

StepsOfFaithPage.propTypes = {};
