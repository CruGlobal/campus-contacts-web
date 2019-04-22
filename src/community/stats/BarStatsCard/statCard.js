// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useSpring, animated } from 'react-spring';

// CSS
const Card = styled(animated.div)`
    background-color: white;
    border-radius: 8px;
    padding: 18px;
`;

const BarStatCardLayout = styled(Card)`
    display: grid;
    grid-template-rows: repeat(3, 1fr);
    grid-column-gap: 30px;
`;

const StatNumber = styled.span`
    font-size: 32px;
    font-weight: bold;
    color: #007398;
`;

const StatLabel = styled.span`
    font-size: 11px;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: lightgrey;
`;

const BarStatCard = ({ count, label }) => {
    const props = useSpring({ marginTop: 0, from: { marginTop: 1000 } });
    return (
        <BarStatCardLayout style={props}>
            <StatNumber>{count}</StatNumber>
            <StatLabel>{label}</StatLabel>
        </BarStatCardLayout>
    );
};

export default BarStatCard;

// PROPTYPES
BarStatCard.propTypes = {
    count: PropTypes.number,
    label: PropTypes.string,
};
