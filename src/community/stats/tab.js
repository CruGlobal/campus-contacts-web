import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';

const Tabs = ({ title, value, active, onTabClick, tabsPosition }) => {
    const TabValue = styled.p`
        font-size: 2rem;
    `;
    const Tab = styled.div`
        display: flex;
        flex-direction: column;
        align-item: flex-start;
        background: ${props => (props.active ? '#007398' : '#3cc8e6')};
        width: 100%;
        height: 70px;
        font-size: 12px;
        color: white;
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
        ::after {
            color: transparent;
            content: '';
            position: absolute;
            top: 375px;
            left: 0;
            right: ${active ? tabsPosition : null}%;
            margin: auto;
            border-bottom: 6px solid white;
            border-left: 6px solid transparent;
            border-right: 6px solid transparent;
            width: 0;
        }
    `;
    return (
        <Tab active={active} onClick={onTabClick}>
            <p>{title}</p>
            <TabValue>{value}</TabValue>
        </Tab>
    );
};

Tabs.propTypes = {
    title: PropTypes.string.isRequired,
    value: PropTypes.string.isRequired,
    active: PropTypes.bool.isRequired,
    onTabClick: PropTypes.func,
};

export default Tabs;
