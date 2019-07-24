import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from 'react-apollo-hooks';
import gql from 'graphql-tag';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';
import moment from 'moment';

import RangePicker from '../../components/RangePicker';

const GET_TOTAL_STEPS_COMPLETED_REPORT = gql`
    query communityReport {
        communityReport {
            communityStagesReport {
                pathwayStage
                personalStepsCompletedCount
            }
        }
    }
`;

const Wrapper = styled.div`
    display: flex;
    flex-direction: column;
`;

const Stages = styled.div`
    display: flex;
    flex-direction: row;
    justify-content: space-around;
`;

const Stage = styled.div`
    display: flex;
    flex-direction: column;
    align-items: center;
`;

const Icon = styled.div`
    height: 52px;
    width: 52px;
    background-size: contain;
    background-repeat: no-repeat;

    &.not-sure {
        background-image: url(/src/dashboard/assets/icons/stage-not-sure.svg);
    }

    &.uninterested {
        background-image: url(src/dashboard/assets/icons/stage-uninterested.svg);
    }

    &.curious {
        background-image: url(./src/dashboard/assets/icons/stage-curious.svg);
    }

    &.forgiven {
        background-image: url(/src/dashboard/assets/icons/stage-forgiven.svg);
    }

    &.growing {
        background-image: url(/src/dashboard/assets/icons/stage-growing.svg);
    }

    &.guiding {
        background-image: url(/src/dashboard/assets/icons/stage-guiding.svg);
    }
`;

const Title = styled.div`
    font-weight: 600;
    font-size: 12px;
    line-height: 14px;
    color: ${({ theme }) => theme.colors.secondary};
    margin-top: 17px;
`;

const Value = styled.div`
    font-weight: 600;
    font-size: 32px;
    line-height: 38px;
    color: ${({ theme }) => theme.colors.highlightDarker};
    margin-top: 9px;
`;

const Footer = styled.div`
    margin-top: 28px;
`;

const PersonalStepsCompletedTotalChart = () => {
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

    return (
        <Wrapper>
            <Stages>
                {report.map(entry => (
                    <Stage key={entry.pathwayStage}>
                        <Icon
                            className={entry.pathwayStage
                                .toLowerCase()
                                .replace(' ', '-')}
                        />
                        <Title>{entry.pathwayStage}</Title>
                        <Value>{entry.personalStepsCompletedCount}</Value>
                    </Stage>
                ))}
            </Stages>
            <Footer>
                <RangePicker
                    onDatesChange={onDatesChange}
                    startDate={dates.startDate}
                    endDate={dates.endDate}
                />
            </Footer>
        </Wrapper>
    );
};

export default withTheme(PersonalStepsCompletedTotalChart);
