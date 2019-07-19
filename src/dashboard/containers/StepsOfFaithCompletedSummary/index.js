import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from 'react-apollo-hooks';
import gql from 'graphql-tag';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';
import moment from 'moment';

import RangePicker from '../../components/RangePicker';
import StagesSummary from '../../components/StagesSummary';

const GET_TOTAL_STEPS_COMPLETED_REPORT = gql`
    query communityReport {
        communityReport {
            communityStagesReport {
                pathwayStage
                otherStepsCompletedCount
            }
        }
    }
`;

const Wrapper = styled.div`
    display: flex;
    flex-direction: column;
`;

const Footer = styled.div`
    margin-top: 28px;
`;

const StepsOfFaithCompletedSummary = () => {
    const [dates, setDates] = useState({
        startDate: moment().subtract(7, 'days'),
        endDate: moment(),
    });

    // To be used when quering data from GraphQL Endpoint
    //console.log('From:', dates.startDate.format('YYYY-MM-DD'));
    //console.log('To:', dates.endDate.format('YYYY-MM-DD'));

    const { data, loading } = useQuery(GET_TOTAL_STEPS_COMPLETED_REPORT);

    const { t } = useTranslation('insights');

    if (loading) {
        return <Wrapper>{t('loading')}</Wrapper>;
    }

    const onDatesChange = ({ startDate, endDate }) => {
        setDates({ startDate, endDate });
    };

    const {
        communityReport: { communityStagesReport: report },
    } = data;

    const summary = report.map(entry => ({
        stage: entry.pathwayStage,
        icon: entry.pathwayStage.toLowerCase().replace(' ', '-'),
        count: entry.otherStepsCompletedCount,
    }));

    return (
        <Wrapper>
            <StagesSummary summary={summary} />
            <Footer>
                <RangePicker onDatesChange={onDatesChange} />
            </Footer>
        </Wrapper>
    );
};

export default withTheme(StepsOfFaithCompletedSummary);
