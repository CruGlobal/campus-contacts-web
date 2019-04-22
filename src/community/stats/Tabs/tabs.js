import React from 'react';
import styled from '@emotion/styled';
import Tab from './tab';
import { useMutation, useQuery } from 'react-apollo-hooks';
import {
    GET_CURRENT_TAB,
    UPDATE_CURRENT_TAB,
    GET_TAB_CONTENT,
} from '../../graphql';
import _ from 'lodash';
import PropTypes from 'prop-types';

const TabsContainer = styled.div`
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    border-radius: 5px 5px 0px 0px;
    overflow: hidden;
`;

const tabContent = () => {
    const { data, loading, error } = useQuery(GET_TAB_CONTENT);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        apolloClient: { tabsContent },
    } = data;

    const TabContent = tabsContent.data;

    return TabContent;
};

const Tabs = () => {
    const { loading, data } = useQuery(GET_CURRENT_TAB);
    const updateCurrentTab = useMutation(UPDATE_CURRENT_TAB);

    const onTabClick = name => {
        if (!name) {
            return;
        }
        updateCurrentTab({ variables: { name } });
    };

    if (loading) {
        return <div>Loading</div>;
    }

    const {
        apolloClient: { currentTab },
    } = data;

    const TabContent = tabContent();

    return (
        <TabsContainer>
            {_.map(TabContent, tab => (
                <Tab
                    title={tab.title}
                    value={tab.stats}
                    key={tab.key}
                    active={currentTab === tab.key ? 'true' : 'false'}
                    onTabClick={() => onTabClick(tab.key)}
                />
            ))}
        </TabsContainer>
    );
};

Tabs.propTypes = {
    currentTab: PropTypes.string,
    title: PropTypes.string,
    value: PropTypes.string,
    key: PropTypes.string,
    active: PropTypes.bool,
    onTabClick: PropTypes.func,
};

export default Tabs;
