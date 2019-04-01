import React from 'react';
import styled from '@emotion/styled';
import Tab from './tab';
import { useMutation, useQuery } from 'react-apollo-hooks';
import { GET_CURRENT_TAB, UPDATE_CURRENT_TAB } from '../../graphql';

const TabsContainer = styled.div`
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    border-radius: 5px 5px 0px 0px;
    overflow: hidden;
`;

const TabsConfig = [
    {
        title: 'PEOPLE/STEPS OF FAITH',
        key: 'MEMBERS',
        stats: '40 / 120',
        tabPosition: '54',
    },
    {
        title: 'STEPS COMPLETED',
        key: 'STEPS_COMPLETED',
        stats: '20',
        tabPosition: '33',
    },
    {
        title: 'PEOPLE MOVEMENT',
        key: 'PEOPLE_MOVEMENT',
        stats: '2',
        tabPosition: '12',
    },
    {},
];

const Tabs = () => {
    const {
        data: {
            apolloClient: { currentTab },
        },
    } = useQuery(GET_CURRENT_TAB);
    const updateCurrentTab = useMutation(UPDATE_CURRENT_TAB);

    const onTabClick = name => {
        if (!name) {
            return;
        }
        updateCurrentTab({ variables: { name } });
    };

    return (
        <TabsContainer>
            {_.map(TabsConfig, tab => (
                <Tab
                    title={tab.title}
                    value={tab.stats}
                    key={tab.key}
                    tabsPosition={tab.tabPosition}
                    active={currentTab === tab.key}
                    onTabClick={() => onTabClick(tab.key)}
                />
            ))}
        </TabsContainer>
    );
};

Tabs.propTypes = {};

export default Tabs;
