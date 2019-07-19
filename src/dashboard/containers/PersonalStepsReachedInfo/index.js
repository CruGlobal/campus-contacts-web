import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from 'react-apollo-hooks';
import gql from 'graphql-tag';

import AppContext from '../../appContext';
import Header from '../../components/Header';

const GET_IMPACT_REPORT = gql`
    query impactReport($organizationId: ID!) {
        impactReport(organizationId: $organizationId) {
            pathwayMovedCount
        }
    }
`;

const PersonalStepsReachedInfo = () => {
    const { orgId } = useContext(AppContext);

    const { data, loading } = useQuery(GET_IMPACT_REPORT, {
        variables: {
            organizationId: orgId,
        },
    });
    const { t } = useTranslation('insights');

    if (loading) {
        return <Header>{t('loading')}</Header>;
    }

    const { impactReport: report } = data;

    return (
        <Header>
            {t('personalSteps.reached', { count: report.pathwayMovedCount })}
        </Header>
    );
};

export default PersonalStepsReachedInfo;
