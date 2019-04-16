import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
import { GET_MEMBERS_GRAPHQL } from '../../graphql';
import BarStatCard from './statCard';
import _ from 'lodash';

const BarChartCardRow = styled.div`
    margin-top: 80px;
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    grid-column-gap: 30px;
`;

const BarStats = ({ style }) => {
    const { data, loading, error } = useQuery(GET_MEMBERS_GRAPHQL);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message} </div>;
    }

    const { organization } = data;

    const orgsList = [];

    // Currently the way the graphql endpoint returns data we must push each stage to
    // a seperate array and then map through that array

    orgsList.push(organization.stage_0);
    orgsList.push(organization.stage_1);
    orgsList.push(organization.stage_2);
    orgsList.push(organization.stage_3);
    orgsList.push(organization.stage_4);
    orgsList.push(organization.stage_5);

    return (
        <BarChartCardRow style={style}>
            {_.map(orgsList, member => (
                <BarStatCard
                    key={member.id}
                    label={member.pathwayStage.name}
                    count={member.memberCount}
                    description={member.pathwayStage.description}
                />
            ))}
        </BarChartCardRow>
    );
};

export default BarStats;

BarStats.propTypes = {
    key: PropTypes.string,
    label: PropTypes.string,
    count: PropTypes.number,
    description: PropTypes.string,
};
