import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';

const StepsContent = styled.p`
color: grey;
font-size: 1.5rem;
margin 0 0 5px 0;
`;

const StepsInfoSpiritual = ({ userStats }) => (
    <StepsContent>
        {userStats} people reached a new stage on their spiritual journey.
    </StepsContent>
);

export default StepsInfoSpiritual;
