import React, { ReactNode, useState } from 'react';
import { Bar } from '@nivo/bar';
import { withTheme } from 'emotion-theming';
import { useTranslation } from 'react-i18next';
import { line } from 'd3-shape';
import styled from '@emotion/styled';

import SwitchButton from '../SwitchButton';
import nullAdded from '../../assets/icons/null-added.svg';
import nullChallenges from '../../assets/icons/null-challenges.svg';
import nullCompleted from '../../assets/icons/null-completed.svg';
import nullInteractions from '../../assets/icons/null-interactions.svg';
import nullStages from '../../assets/icons/null-stages.svg';

const Wrapper = styled.div`
    height: 400px;
    position: relative;
`;

const Line = styled.div`
    border-top: 2px solid ${({ theme }) => theme.colors.highlight};
    width: 26px;
    height: 2px;
    &.dashed {
        border-top-style: dashed;
    }
`;

const Footer = styled.div`
    height: 32px;
    display: flex;
    justify-content: space-between;
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

const TooltipRow = styled.div`
    display: flex;
    justify-content: space-between;
    &.total {
        color: ${({ theme }) => theme.colors.highlight};
    }
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

interface Props {
    theme: any;
    data: any;
    keys: any;
    indexBy: string;
    average?: number;
    filterType: string;
    title?: string;
    subtitle?: string;
    children?: ReactNode;
    index: number;
    datesFilter?: boolean;
    onFilterChanged: (type: string, index: number) => void;
    legendLabel?: string;
    tooltipBreakdown?: boolean;
    nullContent?: string;
}

const BarChart = (props: Props) => {
    const {
        theme,
        data,
        keys,
        indexBy,
        average,
        tooltipBreakdown,
        onFilterChanged,
        index,
        filterType,
        datesFilter,
        legendLabel,
        nullContent,
    } = props;

    const { t } = useTranslation('insights');

    const [filter, setFilter] = useState({
        type: filterType,
        index,
    });

    const AverageLine = ({
        yScale,
        width,
    }: {
        yScale: (value: number) => number;
        width: number;
    }) => {
        if (!average) {
            return null;
        }

        const averageLine = [{ x: 0, y: average }, { x: width, y: average }];

        const lineGenerator = line<{ x: number; y: number }>()
            .x(({ x }) => x)
            .y(({ y }) => yScale(y));

        return (
            <path
                // @ts-ignore
                d={lineGenerator(averageLine)}
                fill="none"
                strokeDasharray="10, 5"
                strokeWidth="2"
                stroke="#B2ECF7"
            />
        );
    };

    const isNullCheck = (data: any) => {
        const nullCheck = data.filter((day: any) => {
            return (
                (day.total && day.total !== 0) ||
                (day.Members && day.Members !== 0) ||
                (day.People && day.People !== 0) ||
                (day.stepsOfFaith && day.stepsOfFaith !== 0) ||
                (day.personalStepsOfFaith && day.personalStepsOfFaith !== 0)
            );
        });

        return nullCheck.length === 0;
    };
    // Depending on the nullContent string, return the correct image
    const getImageSrc = (content: string | undefined) => {
        switch (content) {
            case 'stepsOfFaithCompleted':
            case 'personalStepsCompleted':
                return nullCompleted;
            case 'personalStepsAdded':
            case 'stepsOfFaithAdded':
                return nullAdded;
            case 'communityMembersStages':
            case 'peopleStages':
                return nullStages;
            case 'interactionsCompleted':
                return nullInteractions;
            case 'challengesCompleted':
                return nullChallenges;
            default:
                return null;
        }
    };
    // Create a null element to be added as a layer in the barchart svg
    const creatNull = () => {
        if (isNullCheck(data)) {
            return (
                <g>
                    <rect width={848} fill={'white'} height={300}></rect>
                    <image
                        y="90"
                        x="350"
                        xlinkHref={getImageSrc(nullContent)}
                    />
                    <text
                        transform="translate(400)"
                        y={34}
                        fontSize={16}
                        fontWeight={300}
                        fill={'#007398'}
                        width={720}
                        height={50}
                    >
                        <tspan y="180" x="0" dy="1.4em" textAnchor="middle">
                            {t(`nullState.${nullContent}.part1`)}
                        </tspan>

                        <tspan y="200" x="0" dy="1.6em" textAnchor="middle">
                            {t(`nullState.${nullContent}.part2`)}
                        </tspan>
                    </text>
                </g>
            );
        } else {
            return null;
        }
    };

    const updateFilter = (index: number, type: string) => {
        setFilter({ type, index });
        onFilterChanged(type, index);
    };

    const onToggleFilterClick = (filterType: string) => {
        updateFilter(0, filterType);
    };

    const onNextRangeClick = () => {
        const newIndex = filter.index - 1 >= 0 ? filter.index - 1 : 0;
        updateFilter(newIndex, filter.type);
    };

    const onPreviousRangeClick = () => {
        const newIndex = filter.index + 1;
        updateFilter(newIndex, filter.type);
    };

    const tooltip = (options: any) => {
        const { data } = options;

        return [
            data.stages.map((row: { name: string; count: number }) => (
                <TooltipRow key={row.name}>
                    <Label>{row.name}</Label>
                    <Value>{row.count}</Value>
                </TooltipRow>
            )),
            <TooltipRow className={'total'} key={'total'}>
                <Label>Total</Label>
                <Value>{data.total}</Value>
            </TooltipRow>,
        ];
    };

    return (
        <div>
            <Wrapper>
                <Bar
                    height={400}
                    width={848}
                    data={data}
                    keys={keys}
                    indexBy={indexBy}
                    theme={theme.graph}
                    // @ts-ignore
                    layers={[
                        AverageLine,
                        'grid',
                        'axes',
                        'bars',
                        'markers',
                        'legends',
                        creatNull,
                    ]}
                    margin={{
                        top: 30,
                        right: 0,
                        bottom: 90,
                        left: 30,
                    }}
                    minValue={'auto'}
                    maxValue={'auto'}
                    padding={0.4}
                    innerPadding={3}
                    colors={[
                        theme.colors.highlight,
                        theme.colors.highlightDarker,
                    ]}
                    colorBy="id"
                    axisTop={null}
                    groupMode={'grouped'}
                    axisRight={null}
                    // @ts-ignore
                    tooltip={tooltipBreakdown ? tooltip : null}
                    axisBottom={{
                        tickSize: 0,
                        tickPadding: 20,
                    }}
                    axisLeft={{
                        tickSize: 0,
                        tickPadding: 5,
                        tickRotation: 0,
                    }}
                    enableGridY={true}
                    enableLabel={false}
                    animate={true}
                    motionStiffness={90}
                    motionDamping={15}
                />
                {datesFilter ? (
                    <div>
                        <PreviousButton onClick={onPreviousRangeClick} />
                        <NextButton onClick={onNextRangeClick} />
                    </div>
                ) : null}
            </Wrapper>
            <Footer>
                {datesFilter ? (
                    <SwitchButton
                        isMonth={filter.type === 'month'}
                        leftLabel={t('monthLabel')}
                        rightLabel={t('yearLabel')}
                        onLeftClick={() => onToggleFilterClick('month')}
                        onRightClick={() => onToggleFilterClick('year')}
                    />
                ) : null}
                {legendLabel ? (
                    <Legend>
                        <Line />
                        <LegendLabel>{legendLabel}</LegendLabel>
                        <Line className={'dashed'} />
                        <LegendLabel>{t('average')}</LegendLabel>
                    </Legend>
                ) : null}
            </Footer>
        </div>
    );
};

export default withTheme(BarChart);
