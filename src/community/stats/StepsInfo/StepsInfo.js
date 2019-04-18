import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import StepsInfoPersonal from './stepsInfoPersonal';
import StepsInfoSpiritual from './stepsInfoSpiritual';
import { useSpring, animated } from 'react-spring';

const Container = styled(animated.div)`
    margin-top: 150px;
`;

const StepsInfo = () => {
    const props = useSpring({
        delay: '1500',
        opacity: 1,
        from: { opacity: 0 },
    });

    return (
        <Container style={props}>
            <StepsInfoPersonal />
            <StepsInfoSpiritual />
        </Container>
    );
};

export default StepsInfo;
