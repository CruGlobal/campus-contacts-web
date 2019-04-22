import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
import { GET_MEMBERS_GRAPHQL, GET_MEMBERS } from '../../graphql';
import BarStatCard from './statCard';
import _ from 'lodash';
import { useSpring, animated } from 'react-spring';

const BarChartCardRow = styled(animated.div)`
    margin-top: 80px;
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    grid-column-gap: 30px;
`;

const BarStats = () => {
    // const { data, loading, error } = useQuery(GET_MEMBERS_GRAPHQL);

    // if (loading) {
    //     return <div>Loading...</div>;
    // }

    // if (error) {
    //     return <div>Error! {error.message} </div>;
    // }

    // const { organization } = data;

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

    // UseSpring seems to break test on this component
    // const props = useSpring({ marginTop: 80, from: { marginTop: 1000 } });

    return (
        <BarChartCardRow>
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

BarStats.propTypes = {
    key: PropTypes.string,
    members: PropTypes.object,
    label: PropTypes.string,
    count: PropTypes.number,
};
