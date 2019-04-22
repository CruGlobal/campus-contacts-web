// COMPONENTS
import FilterOption from './filterOption';
// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import moment from 'moment';
import { useMutation, useQuery } from 'react-apollo-hooks';
// QUERIES
import { GET_CURRENT_FILTER, UPDATE_CURRENT_FILTER } from '../../graphql';

// CSS
const Container = styled.div`
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    color: lightgrey;
    > div {
        > p {
            margin: 0 -50px 0 -20px;
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

const FilterConfig = [
    {
        title: 'ALL',
        filter: {
            key: 'ALL',
            startDate: moment()
                .subtract(5, 'years')
                .startOf('year')
                .format('l'),
            endDate: moment()
                .endOf('year')
                .format('l'),
        },
    },
    {
        title: '1W',
        filter: {
            key: '1W',
            startDate: moment()
                .subtract(1, 'week')
                .format('l'),
            endDate: moment().format('l'),
        },
    },
    {
        title: '1M',
        filter: {
            key: '1M',
            startDate: moment()
                .subtract(1, 'month')
                .format('l'),
            endDate: moment().format('l'),
        },
    },
    {
        title: '3M',
        filter: {
            key: '3M',
            startDate: moment()
                .subtract(3, 'month')
                .format('l'),
            endDate: moment().format('l'),
        },
    },
    {
        title: '6M',
        filter: {
            key: '6M',
            startDate: moment()
                .subtract(6, 'month')
                .format('l'),
            endDate: moment().format('l'),
        },
    },
    {
        title: '1Y',
        filter: {
            key: '1Y',
            startDate: moment()
                .subtract(1, 'year')
                .format('l'),
            endDate: moment().format('l'),
        },
    },
];

const Filters = () => {
    const { data, loading } = useQuery(GET_CURRENT_FILTER);

    if (loading) {
        return <div>Loading</div>;
    }

    const updateCurrentFilter = useMutation(UPDATE_CURRENT_FILTER);
    const onFilterClick = filter => {
        updateCurrentFilter({ variables: { filter } });
    };

    const {
        apolloClient: {
            currentFilter: { key, startDate, endDate },
        },
    } = data;

    return (
        <Container>
            <DateContainer>
                {_.map(FilterConfig, option => (
                    <FilterOption
                        key={option.filter.key}
                        title={option.title}
                        filter={option.filter}
                        active={option.filter.key === key}
                        onFilterClick={onFilterClick}
                    />
                ))}
            </DateContainer>
            <WeekContainer>
                <p>{startDate}</p>
                <p>{endDate}</p>
            </WeekContainer>
        </Container>
    );
};

export default Filters;

// PROPTYPES
Filters.propTypes = {
    date: PropTypes.string,
    title: PropTypes.string,
    filter: PropTypes.object,
    active: PropTypes.bool,
    key: PropTypes.string,
    onFilterClick: PropTypes.func,
    currentFilter: PropTypes.object,
    endDate: PropTypes.string,
    startDate: PropTypes.string,
};
