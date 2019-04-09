import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';

const StepsContent = styled.p`
color: grey;
font-size: 1.5rem;
margin 0 0 5px 0;
`;

const StepsInfoPersonal = ({ userStats, numberStats, peopleStats }) => (
    <StepsContent>
        {userStats} members have taken {numberStats} steps with {peopleStats}{' '}
        people.
    </StepsContent>
);

export default StepsInfoPersonal;
