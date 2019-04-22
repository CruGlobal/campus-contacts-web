// COMPONENTS
import StepsInfoPersonal from './stepsInfoPersonal';
import StepsInfoSpiritual from './stepsInfoSpiritual';
// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useSpring, animated } from 'react-spring';

// CSS
const Container = styled(animated.div)`
    margin-top: 150px;
`;

const StepsInfo = () => {
    // ANIMATION
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

// PROPTYPES
StepsInfo.propTypes = {
    style: PropTypes.object,
};
