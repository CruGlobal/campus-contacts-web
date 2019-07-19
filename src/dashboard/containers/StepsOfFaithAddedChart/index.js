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
            memberCount
            pathwayStage {
                name
            }
            othersStepsAddedCount
        }
    }
`;

const Wrapper = styled.div`
    height: 400px;
`;

const StepsOfFaithAddedChart = () => {
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

    const LABEL = t('stepsOfFaith.legendLabel');
    const STAGE_LABEL = t('stage');

    const graphData = report.map(row => ({
        [LABEL]: row.othersStepsAddedCount,
        [STAGE_LABEL]: row.pathwayStage.name.toUpperCase(),
    }));

    return (
        <Wrapper>
            <BarChart data={graphData} keys={[LABEL]} indexBy={STAGE_LABEL} />
        </Wrapper>
    );
};

export default StepsOfFaithAddedChart;
