// COMPONENTS
import BarStatCard from './statCard';
// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import _ from 'lodash';
import { useQuery } from 'react-apollo-hooks';
// QUERIES
import { GET_MEMBERS } from '../../graphql';

// CSS
const BarChartCardRow = styled.div`
    margin-top: 80px;
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    grid-column-gap: 30px;
`;

const BarStats = () => {
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

    const MembersData = members.data;

    return (
        <BarChartCardRow>
            {_.map(MembersData, member => (
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

// PROPTYPES
BarStats.propTypes = {
    members: PropTypes.object,
    key: PropTypes.string,
    label: PropTypes.string,
    count: PropTypes.number,
};
