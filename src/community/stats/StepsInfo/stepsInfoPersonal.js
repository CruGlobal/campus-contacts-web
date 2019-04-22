// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
// QUERIES
import { GET_STEPSINFO_PERSONAL } from '../../graphql';

// CSS
const StepsContent = styled.p`
color: grey;
font-size: 1.5rem;
margin 0 0 5px 0;
`;

const StepsInfoPersonal = () => {
    const { data, loading, error } = useQuery(GET_STEPSINFO_PERSONAL);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        apolloClient: { stepsInfoPersonal },
    } = data;

    const { userStats, numberStats, peopleStats } = stepsInfoPersonal;

    return (
        <StepsContent>
            {userStats} members have taken {numberStats} steps with{' '}
            {peopleStats} people.
        </StepsContent>
    );
};

export default StepsInfoPersonal;

// PROPTYPES
StepsInfoPersonal.propTypes = {
    stepsInfoPersonal: PropTypes.object,
    userStats: PropTypes.string,
    numberStats: PropTypes.string,
    peopleStats: PropTypes.string,
};
