import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import StepsInfoPersonal from './stepsInfoPersonal';
import StepsInfoSpiritual from './stepsInfoSpiritual';

const Container = styled.div`
    margin-top: 150px;
`;

const StepsInfo = ({ style }) => {
    return (
        <Container style={style}>
            <StepsInfoPersonal />
            <StepsInfoSpiritual />
        </Container>
    );
};

export default StepsInfo;
