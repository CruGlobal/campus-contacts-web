import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from 'react-apollo-hooks';
import gql from 'graphql-tag';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';
import _ from 'lodash';

import BarChart from '../../components/BarChart';

const GET_STEPS_COMPLETED_REPORT = gql`
    query communityReport {
        communityReport {
            dayReport {
                date
                personalStepsCompletedCount
                communityStagesReport {
                    pathwayStage
                    personalStepsCompletedCount
                }
            }
        }
    }
`;

const Wrapper = styled.div`
    height: 400px;
    position: relative;
`;

const PersonalStepsCompletedChart = () => {
    const [dates, setDates] = useState({});

    const { data, loading } = useQuery(GET_STEPS_COMPLETED_REPORT);
    const { t } = useTranslation('insights');

    if (loading) {
        return <Wrapper>{t('loading')}</Wrapper>;
    }

    // To be used when quering data from GraphQL Endpoint
    // console.log('From:', dates[0].format('YYYY-MM-DD'));
    // console.log('To:', dates[1].format('YYYY-MM-DD'));

    const {
        communityReport: { dayReport: report },
    } = data;

    const graphData = report.map(row => ({
        ['total']: row.personalStepsCompletedCount,
        ['stages']: row.communityStagesReport.map(stage => ({
            name: stage.pathwayStage,
            count: stage.personalStepsCompletedCount,
        })),
        ['date']: row.date.substring(0, 2),
    }));

    const average = Math.floor(_.sumBy(graphData, 'total') / graphData.length);

    return (
        <BarChart
            data={graphData}
            keys={['total']}
            indexBy={'date'}
            average={average}
            tooltipBreakdown={true}
            datesFilter={true}
            onDatesChanged={dates => {
                setDates(dates);
            }}
            legendLabel={t('personalSteps.legend')}
        />
    );
};

export default withTheme(PersonalStepsCompletedChart);
