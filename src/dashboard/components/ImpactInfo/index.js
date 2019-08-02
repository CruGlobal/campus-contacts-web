import { useTranslation } from 'react-i18next';
import { useQuery } from 'react-apollo-hooks';
import React from 'react';

import Header from '../Header';

const ImpactInfo = ({ query, text, variables }) => {
    const { data, loading } = useQuery(query, { variables });
    const { t } = useTranslation('insights');

    if (loading) {
        return <Header>{t('loading')}</Header>;
    }
    return <Header>{text(data)} </Header>;
};

export default ImpactInfo;
