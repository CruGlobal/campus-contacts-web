import React from 'react';
import { useTranslation } from 'react-i18next';

import Card from '../../components/Card';

const StepsOfFaithPage = () => {
    const { t } = useTranslation('insights');

    return (
        <div>
            <Card title={t('steps.title')} />
        </div>
    );
};

export default StepsOfFaithPage;

StepsOfFaithPage.propTypes = {};
