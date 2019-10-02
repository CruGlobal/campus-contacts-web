import React, { useState } from 'react';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';
import PropTypes from 'prop-types';
import moment, { Moment } from 'moment';
import { useQuery } from 'react-apollo-hooks';
import { useTranslation } from 'react-i18next';

import RangePicker from '../RangePicker';
import notSure from '../../assets/icons/stage-not-sure.svg';
import uninterested from '../../assets/icons/stage-uninterested.svg';
import curious from '../../assets/icons/stage-curious.svg';
import forgiven from '../../assets/icons/stage-forgiven.svg';
import growing from '../../assets/icons/stage-growing.svg';
import guiding from '../../assets/icons/stage-guiding.svg';
import spiritual from '../../assets/icons/stage-spiritual-conversations.svg';
import gospel from '../../assets/icons/stage-gospel-presentations.svg';
import holySpirit from '../../assets/icons/stage-holy-spirit-conversations.svg';
import personal from '../../assets/icons/stage-personal-decisions.svg';
import discipleship from '../../assets/icons/stage-discipleship-conversations.svg';
import { stepsOfFaithMockData } from '../NullState';
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
        background-image: url(${notSure});
    }

    &.uninterested {
        background-image: url(${uninterested});
    }

    &.curious {
        background-image: url(${curious});
    }

    &.forgiven {
        background-image: url(${forgiven});
    }

    &.growing {
        background-image: url(${growing});
    }

    &.guiding {
        background-image: url(${guiding});
    }

    &.discipleship-conversation {
        background-image: url(${discipleship});
    }

    &.personal-evangelism {
        background-image: url(${gospel});
    }

    &.holy-spirit-presentation {
        background-image: url(${holySpirit});
    }

    &.personal-evangelism-decisions {
        background-image: url(${personal});
    }

    &.spiritual-conversation {
        background-image: url(${spiritual});
    }
`;

interface TitleProps {
    longNames?: boolean;
}

const Title = styled.div<TitleProps>`
    font-weight: 600;
    font-size: 12px;
    line-height: 14px;
    color: ${({ theme }) => theme.colors.secondary};
    margin-top: 17px;
    text-transform: uppercase;
    overflow-wrap: break-word;
    width: 110px;
    text-align: center;
    height: ${(props: TitleProps) => (props.longNames ? '42px' : '14px')};
`;

const Value = styled.div`
    font-weight: 600;
    font-size: 32px;
    line-height: 38px;
    color: ${({ theme }) => theme.colors.highlightDarker};
    margin-top: 9px;
`;

const SummaryWrapper = styled.div`
    display: flex;
    flex-direction: column;
`;

const Footer = styled.div`
    margin-top: 28px;
`;

interface Props {
    query: any;
    mapData: (data: any) => any;
    variables: any;
    longNames?: boolean;
}

const StagesSummary = ({ query, variables, mapData, longNames }: Props) => {
    const [dates, setDates] = useState({
        startDate: moment().subtract(7, 'days'),
        endDate: moment(),
    });
    const days = (dates: any) => {
        return Math.round(
            moment.duration(dates.endDate.diff(dates.startDate)).asDays(),
        );
    };
    const { data, loading } = useQuery(query, {
        variables: {
            ...variables,
            endDate: dates.endDate.toDate(),
            period: `P${days(dates)}D`,
        },
    });

    const onDatesChange = ({
        startDate,
        endDate,
    }: {
        startDate: Moment;
        endDate: Moment;
    }) => {
        setDates({ startDate, endDate });
    };
    if (loading) {
        return (
            <SummaryWrapper>
                <Stages>
                    {mapData(stepsOfFaithMockData).map((entry: any) => (
                        <Stage key={entry.stage}>
                            <Icon className={entry.icon} />
                            <Title longNames={longNames}>{entry.stage}</Title>
                            <Value>{entry.count ? entry.count : '-'}</Value>
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
            </SummaryWrapper>
        );
    }
    return (
        <SummaryWrapper>
            <Stages>
                {mapData(data).map((entry: any) => {
                    return (
                        <Stage key={entry.stage}>
                            <Icon className={entry.icon} />
                            <Title longNames={longNames}>{entry.stage}</Title>
                            <Value>{entry.count ? entry.count : '-'}</Value>
                        </Stage>
                    );
                })}
            </Stages>
            <Footer>
                <RangePicker
                    onDatesChange={onDatesChange}
                    startDate={dates.startDate}
                    endDate={dates.endDate}
                />
            </Footer>
        </SummaryWrapper>
    );
};

export default withTheme(StagesSummary);
