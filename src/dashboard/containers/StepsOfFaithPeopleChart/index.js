import React, { useContext } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from 'react-apollo-hooks';
import gql from 'graphql-tag';
import styled from '@emotion/styled';
import moment from 'moment';

import BarChart from '../../components/BarChart';
import AppContext from '../../appContext';

const GET_STAGES_REPORT = gql`
    query organizationPathwayStagesReport(
        $period: String!
        $organizationId: ID!
        $endDate: ISO8601DateTime!
    ) {
        organizationPathwayStagesReport(
            period: $period
            organizationId: $organizationId
            endDate: $endDate
        ) {
            pathwayStage {
                name
            }
        }
    }
`;

const Wrapper = styled.div`
    height: 400px;
`;

const StepsOfFaithPeopleChart = () => {
    const { orgId } = useContext(AppContext);

    const { data, loading } = useQuery(GET_STAGES_REPORT, {
        variables: {
            period: '',
            organizationId: orgId,
            endDate: moment().format(),
        },
    });

    const { t } = useTranslation('insights');

    if (loading) {
        return <Wrapper>{t('loading')}</Wrapper>;
    }

    const { organizationPathwayStagesReport: report } = data;

    const PEOPLE_LABEL = t('stepsOfFaith.peopleLabel');
    const LABEL = t('stage');

    const graphData = report.map(row => ({
        [PEOPLE_LABEL]: row.memberCount,
        [LABEL]: row.pathwayStage.name.toUpperCase(),
    }));

    return (
        <Wrapper>
            <BarChart data={graphData} keys={[PEOPLE_LABEL]} indexBy={LABEL} />
        </Wrapper>
    );
};

export default StepsOfFaithPeopleChart;
