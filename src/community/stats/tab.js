import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';

let trianglePosition = 54;
// Need to figure out a way to make the little triangle tab move based on the tab clicked
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
        right: ${trianglePosition}%;
        margin: auto;
        border-bottom: 6px solid white;
        border-left: 6px solid transparent;
        border-right: 6px solid transparent;
        width: 0;
    }
`;

const SecondTab = styled(Tab)`
    ::after {
        color: transparent;
        content: '';
        position: absolute;
        top: 375px;
        left: 0;
        right: 33%;
        margin: auto;
        border-bottom: 6px solid white;
        border-left: 6px solid transparent;
        border-right: 6px solid transparent;
        width: 0;
    }
`;

const ThirdTab = styled(Tab)`
    ::after {
        color: transparent;
        content: '';
        position: absolute;
        top: 375px;
        left: 0;
        right: 12%;
        margin: auto;
        border-bottom: 6px solid white;
        border-left: 6px solid transparent;
        border-right: 6px solid transparent;
        width: 0;
    }
`;

const NoTriangle = styled(Tab)`
    ::after {
        color: transparent;
        content: '';
        position: absolute;
        top: 375px;
        left: 0;
        right: 33%;
        margin: auto;
        border-bottom: 6px solid transparent;
        border-left: 6px solid transparent;
        border-right: 6px solid transparent;
        width: 0;
    }
`;

const TabValue = styled.p`
    font-size: 2rem;
`;

// Solution of conditional rendering for the triangle tab
// Better solution will be needed in future

const Tabs = ({ title, value, active, onTabClick }) => {
    return title === 'PEOPLE/STEPS OF FAITH' && active ? (
        <Tab active={active} onClick={onTabClick}>
            <p>{title}</p>
            <TabValue>{value}</TabValue>
        </Tab>
    ) : title === 'STEPS COMPLETED' && active ? (
        <SecondTab active={active} onClick={onTabClick}>
            <p>{title}</p>
            <TabValue>{value}</TabValue>
        </SecondTab>
    ) : title === 'PEOPLE MOVEMENT' && active ? (
        <ThirdTab active={active} onClick={onTabClick}>
            <p>{title}</p>
            <TabValue>{value}</TabValue>
        </ThirdTab>
    ) : (
        <NoTriangle active={active} onClick={onTabClick}>
            <p>{title}</p>
            <TabValue>{value}</TabValue>
        </NoTriangle>
    );
};

Tabs.propTypes = {
    title: PropTypes.string.isRequired,
    value: PropTypes.string.isRequired,
    active: PropTypes.bool.isRequired,
    onTabClick: PropTypes.func,
};

export default Tabs;
