// COMPONENTS
import Tab from './tab';
// LIBRARIES
import React from 'react';
import styled from '@emotion/styled';
import { useMutation, useQuery } from 'react-apollo-hooks';
import _ from 'lodash';
import PropTypes from 'prop-types';
// QUERIES
import { GET_CURRENT_TAB, UPDATE_CURRENT_TAB } from '../../graphql';

// CSS
const TabsContainer = styled.div`
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    border-radius: 5px 5px 0px 0px;
    overflow: hidden;
`;

const Tabs = ({ tabsContent }) => {
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

    return (
        <TabsContainer>
            {_.map(tabsContent, tab => (
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

export default Tabs;

// PROPTYPES
Tabs.propTypes = {
    currentTab: PropTypes.string,
    title: PropTypes.string,
    value: PropTypes.string,
    key: PropTypes.string,
    active: PropTypes.bool,
    onTabClick: PropTypes.func,
};
