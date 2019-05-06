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

const StepsInfoPersonal = ({ orgID }) => {
    const { data, loading, error } = useQuery(GET_IMPACT_REPORT, {
        variables: { id: orgID },
    });

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const { impactReport } = data;

    const { stepsCount, receiversCount, stepOwnersCount } = impactReport;

    return (
        <>
            {stepOwnersCount > 1 ? (
                <StepsContent>
                    {stepOwnersCount} members have taken {stepsCount} steps with{' '}
                    {receiversCount} people.
                </StepsContent>
            ) : (
                <StepsContent>
                    {stepOwnersCount} member has taken {stepsCount} steps with{' '}
                    {receiversCount} people.
                </StepsContent>
            )}
        </>
    );
};

export default StepsInfoPersonal;

// PROPTYPES
StepsInfoPersonal.propTypes = {
    impactReport: PropTypes.object,
    stepOwnersCount: PropTypes.string,
    stepsCount: PropTypes.string,
    receiversCount: PropTypes.string,
};
