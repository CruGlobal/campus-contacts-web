import React from 'react';
import { useTranslation } from 'react-i18next';

import Card from '../../components/Card';
import MemberStagesChart from '../MemberStagesChart';

const PersonalStepsPage = () => {
    const { t } = useTranslation('insights');

    return (
        <div>
            <Card
                title={t('personalStepsCompleted')}
                subtitle={t('personalStepsTotal')}
            />
            <Card
                title={t('currentPersonalSteps')}
                subtitle={t('membersTotal')}
            >
                <MemberStagesChart />
            </Card>
            <Card title={t('membersMovement')} subtitle={t('membersChanged')} />
        </div>
    );
};

export default PersonalStepsPage;

PersonalStepsPage.propTypes = {};
