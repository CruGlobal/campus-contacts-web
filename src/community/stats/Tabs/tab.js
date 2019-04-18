import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { css } from '@emotion/core';
import { useSpring, animated } from 'react-spring';

const Tab = ({ title, value, active, onTabClick }) => {
    const TabValue = styled.p`
        font-size: 2rem;
    `;

    const arrow = css`
        ::after {
            color: transparent;
            content: '';
            position: absolute;
            bottom: 0;
            left: 7%;
            margin: auto;
            border-bottom: 6px solid white;
            border-left: 6px solid transparent;
            border-right: 6px solid transparent;
            width: 0;
        }
    `;

    const Tab = styled(animated.div)`
        display: flex;
        flex-direction: column;
        align-item: flex-start;
        width: 100%;
        height: 70px;
        font-size: 12px;
        color: white;
        position: relative;
        > p {
            margin-left: 10px;
            margin-top: 5px;
            margin-bottom: -10px;
        }
        :not(:last-child) {
            border-right: 1px solid white;
        }
        :hover {
            cursor: pointer;
            opacity: 0.7;
        }
        ${active === 'true' ? arrow : null}
    `;

    const props = useSpring({
        background: active === 'true' ? '#007398' : '#3cc8e6',
    });
    return (
        <Tab style={props} active={active} onClick={onTabClick}>
            <p>{title}</p>
            <TabValue>{value}</TabValue>
        </Tab>
    );
};

Tab.propTypes = {
    title: PropTypes.string.isRequired,
    value: PropTypes.string.isRequired,
    active: PropTypes.string.isRequired,
    onTabClick: PropTypes.func,
};

export default Tab;
