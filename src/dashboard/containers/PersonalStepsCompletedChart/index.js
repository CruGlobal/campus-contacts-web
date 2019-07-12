import React, { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from 'react-apollo-hooks';
import gql from 'graphql-tag';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';
import _ from 'lodash';
import moment from 'moment';

import BarChart from '../../components/BarChart';
import SwitchButton from '../../components/SwitchButton';

const GET_STEPS_COMPLETED_REPORT = gql`
    query communityReport {
        communityReport {
            dayReport {
                date
                stepsCompletedCount
                communityStagesReport {
                    pathwayStage
                    stepsCompletedCount
                }
            }
        }
    }
`;

const Wrapper = styled.div`
    height: 400px;
    position: relative;
`;

const Footer = styled.div`
    height: 32px;
    display: flex;
    justify-content: space-between;
`;

const TooltipRow = styled.div`
    display: flex;
    justify-content: space-between;

    &.total {
        color: ${({ theme }) => theme.colors.highlight};
    }
`;

const Line = styled.div`
    border-top: 2px solid ${({ theme }) => theme.colors.highlight};
    width: 26px;
    height: 2px;

    &.dashed {
        border-top-style: dashed;
    }
`;

const Legend = styled.div`
    display: flex;
    align-items: center;
`;

const LegendLabel = styled.div`
    font-size: 12px;
    line-height: 16px;
    color: ${({ theme }) => theme.colors.secondary};
    margin-left: 5px;
    margin-right: 10px;
`;

const Label = styled.div`
    font-weight: 600;
    font-size: 10px;
    line-height: 20px;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-right: 20px;
`;

const Value = styled.div`
    font-weight: 600;
    font-size: 10px;
    line-height: 20px;
    text-transform: uppercase;
    letter-spacing: 1px;
    align-self: flex-end;
`;

const PreviousButton = styled.div`
    width: 6px;
    height: 12px;
    border-top: 6px solid transparent;
    border-bottom: 6px solid transparent;
    border-right: 6px solid #b4b6ba;
    position: absolute;
    bottom: 57px;
    left: 19px;
    cursor: pointer;

    &:hover {
        border-right: 6px solid #c3c3c3;
    }
`;

const NextButton = styled.div`
    width: 6px;
    height: 12px;
    border-top: 6px solid transparent;
    border-bottom: 6px solid transparent;
    border-left: 6px solid #b4b6ba;
    position: absolute;
    bottom: 57px;
    right: -10px;
    cursor: pointer;

    &:hover {
        border-left: 6px solid #c3c3c3;
    }
`;

const PersonalStepsCompletedChart = () => {
    const [filter, setFilter] = useState({
        type: 'month',
        index: 0,
        datesRange: [moment().subtract(1, 'month'), moment()],
    });

    const { data, loading } = useQuery(GET_STEPS_COMPLETED_REPORT);
    const { t } = useTranslation('insights');

    if (loading) {
        return <Wrapper>{t('loading')}</Wrapper>;
    }

    // To be used when quering data from GraphQL Endpoint
    // console.log('From:', filter.datesRange[0].format('YYYY-MM-DD'));
    // console.log('To:', filter.datesRange[1].format('YYYY-MM-DD'));

    const updateDateRange = (index, type) => {
        setFilter({
            type,
            index,
            datesRange: [
                moment().subtract(index + 1, type),
                moment().subtract(index, type),
            ],
        });
    };

    const onToggleFilterClick = filterType => {
        updateDateRange(0, filterType);
    };

    const onNextRangeClick = () => {
        const newIndex = filter.index - 1 >= 0 ? filter.index - 1 : 0;
        updateDateRange(newIndex, filter.type);
    };

    const onPreviousRangeClick = () => {
        const newIndex = filter.index + 1;
        updateDateRange(newIndex, filter.type);
    };

    const {
        communityReport: { dayReport: report },
    } = data;

    const tooltip = options => {
        const { data } = options;

        return [
            data.stages.map(row => (
                <TooltipRow key={row.name}>
                    <Label>{row.name}</Label>
                    <Value>{row.count}</Value>
                </TooltipRow>
            )),
            <TooltipRow className={'total'} key={'total'}>
                <Label>Total</Label>
                <Value>{data.stepsTotal}</Value>
            </TooltipRow>,
        ];
    };

    const graphData = report.map(row => ({
        ['stepsTotal']: row.stepsCompletedCount,
        ['stages']: row.communityStagesReport.map(stage => ({
            name: stage.pathwayStage,
            count: stage.stepsCompletedCount,
        })),
        ['date']: row.date.substring(0, 2),
    }));

    const average = Math.floor(
        _.sumBy(graphData, 'stepsTotal') / graphData.length,
    );

    return (
        <div>
            <Wrapper>
                <BarChart
                    data={graphData}
                    keys={['stepsTotal']}
                    indexBy={'date'}
                    average={average}
                    tooltip={tooltip}
                />
                <PreviousButton onClick={onPreviousRangeClick} />
                <NextButton onClick={onNextRangeClick} />
            </Wrapper>
            <Footer>
                <SwitchButton
                    leftLabel={t('monthLabel')}
                    rightLabel={t('yearLabel')}
                    onLeftClick={() => onToggleFilterClick('month')}
                    onRightClick={() => onToggleFilterClick('year')}
                />
                <Legend>
                    <Line className={'dashed'} />
                    <LegendLabel>Average</LegendLabel>
                    <Line />
                    <LegendLabel>Steps of Faith</LegendLabel>
                </Legend>
            </Footer>
        </div>
    );
};

export default withTheme(PersonalStepsCompletedChart);
