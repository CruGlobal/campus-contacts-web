// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
// QUERIES
import { GET_STEPSINFO_SPIRITUAL } from '../../graphql';

// CSS
const StepsContent = styled.p`
color: grey;
font-size: 1.5rem;
margin 0 0 5px 0;
`;

const StepsInfoSpiritual = () => {
    const { data, loading, error } = useQuery(GET_STEPSINFO_SPIRITUAL);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        apolloClient: { stepsInfoSpiritual },
    } = data;

    const { userStats } = stepsInfoSpiritual;

    return (
        <StepsContent>
            {userStats} people reached a new stage on their spiritual journey.
        </StepsContent>
    );
};

export default StepsInfoSpiritual;

// PROPTYPES
StepsInfoSpiritual.propTypes = {
    stepsInfoSpiritual: PropTypes.object,
    userStats: PropTypes.string,
};
