import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
import { GET_MEMBERS } from '../../graphql';
import BarStatCard from './statCard';

const BarChartCardRow = styled.div`
    margin-top: 80px;
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    grid-column-gap: 30px;
`;

const BarStats = ({ style }) => {
    const { data, loading, error } = useQuery(GET_MEMBERS);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        apolloClient: { members },
    } = data;

    return (
        <BarChartCardRow style={style}>
            {_.map(members.data, member => (
                <BarStatCard
                    key={member.stage}
                    label={member.stage}
                    count={member.members}
                />
            ))}
        </BarChartCardRow>
    );
};

export default BarStats;

BarStats.propTypes = {};
