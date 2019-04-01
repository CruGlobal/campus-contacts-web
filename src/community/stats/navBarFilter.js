import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';

const Container = styled.div`
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: lightgrey;
    > div {
        > p {
            :hover {
                color: #007397;
                cursor: pointer;
            }
        }
    }
`;

const DateContainer = styled.div`
    width: 50%;
    display: flex;
    justify-content: space-evenly;
`;

const WeekContainer = styled.div`
    width: 50%;
    display: flex;
    justify-content: space-evenly;
`;

const DateConfig = [
    {
        title: 'ALL',
        key: 'ALL',
    },
    {
        title: '1W',
        key: '1W',
    },
    {
        title: '1M',
        key: '1M',
    },
    {
        title: '3M',
        key: '3M',
    },
    {
        title: '6M',
        key: '6M',
    },
    {
        title: '1Y',
        key: '1Y',
    },
];

const SelectedDatesConfig = [
    {
        date: '3/19/2019',
        key: '3/19/2019',
    },
    {
        date: '3/26/2019',
        key: '3/26/2019',
    },
];

const Filters = () => {
    return (
        <Container>
            <DateContainer>
                {_.map(DateConfig, date => (
                    <p key={date.key}>{date.title}</p>
                ))}
            </DateContainer>
            <WeekContainer>
                {_.map(SelectedDatesConfig, week => (
                    <p key={week.key}>{week.date}</p>
                ))}
            </WeekContainer>
        </Container>
    );
};

Filters.protoTypes = {
    date: PropTypes.string.isRequired,
};

export default Filters;
