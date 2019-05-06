// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
// QUERIES
import { GET_IMPACT_REPORT } from '../../graphql';

// CSS
const StepsContent = styled.p`
color: grey;
font-size: 1.5rem;
margin 0 0 5px 0;
`;

const StepsInfoSpiritual = ({ orgID }) => {
    const { data, loading, error } = useQuery(GET_IMPACT_REPORT, {
        variables: { id: orgID },
    });

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        impactReport: { pathwayMovedCount },
    } = data;

    return (
        <StepsContent>
            {pathwayMovedCount} people reached a new stage on their spiritual
            journey.
        </StepsContent>
    );
};

export default StepsInfoSpiritual;

// PROPTYPES
StepsInfoSpiritual.propTypes = {
    impactReport: PropTypes.object,
    pathwayMovedCount: PropTypes.string,
};
