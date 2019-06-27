import React from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from 'react-apollo-hooks';
import gql from 'graphql-tag';
import styled from '@emotion/styled';

import BarChart from '../../components/BarChart';

const GET_STAGE_REPORT = gql`
    query stages_report {
        stages_report {
            data {
                pathway_stage
                member_count
                steps_added_count
                steps_completed_count
            }
        }
    }
`;

const Wrapper = styled.div`
    height: 400px;
`;

const MemberStagesChart = () => {
    const { data, loading } = useQuery(GET_STAGE_REPORT);
    const { t } = useTranslation('insights');

    if (loading) {
        return <Wrapper>{t('loading')}</Wrapper>;
    }

    const { stages_report: report } = data;

    const MEMBERS_LABEL = t('members');
    const STAGE_LABEL = t('stage');

    const graphData = report.data.map(row => ({
        [MEMBERS_LABEL]: row.member_count,
        [STAGE_LABEL]: row.pathway_stage,
    }));

    return (
        <Wrapper>
            <BarChart
                data={graphData}
                keys={[MEMBERS_LABEL]}
                indexBy={STAGE_LABEL}
            />
        </Wrapper>
    );
};

export default MemberStagesChart;
