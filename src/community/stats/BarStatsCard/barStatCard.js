import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
import { GET_MEMBERS } from '../../graphql';

const BarChartCardRow = styled.div`
    margin-top: 80px;
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    grid-column-gap: 30px;
`;

const Card = styled.div`
    background-color: white;
    border-radius: 8px;
    padding: 18px;
`;

const BarStatCardLayout = styled(Card)`
    display: grid;
    grid-template-rows: repeat(3, 1fr);
    grid-column-gap: 30px;
`;

const StatNumber = styled.span`
    font-size: 32px;
    font-weight: bold;
    color: #007398;
`;

const StatLabel = styled.span`
    font-size: 11px;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: ${({
        theme: {
            colors: { light },
        },
    }) => light};
`;

const BarStatCard = ({ count, label }) => (
    <BarStatCardLayout>
        <StatNumber>{count}</StatNumber>
        <StatLabel>{label}</StatLabel>
    </BarStatCardLayout>
);

const BarStats = ({ style }) => {
    const {
        data: {
            apolloClient: { members },
            error,
            loading,
        },
    } = useQuery(GET_MEMBERS);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

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
