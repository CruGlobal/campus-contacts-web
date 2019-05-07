// COMPONENTS
import Tab from './tab';
// LIBRARIES
import React from 'react';
import angular from 'angular';
import styled from '@emotion/styled';
import { useMutation, useQuery } from 'react-apollo-hooks';
import PropTypes from 'prop-types';
import _ from 'lodash';
// QUERIES
import {
    GET_CURRENT_TAB,
    UPDATE_CURRENT_TAB,
    GET_IMPACT_REPORT,
} from '../../graphql';

// CSS
const TabsContainer = styled.div`
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    border-radius: 5px 5px 0px 0px;
    overflow: hidden;
`;

const Tabs = ({ tabsContent, orgID }) => {
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

    const getTabsContent = () => {
        const { data, loading } = useQuery(GET_IMPACT_REPORT, {
            variables: { id: orgID },
        });

        if (loading) {
            return <div>Loading</div>;
        }

        const {
            impactReport: { stepsCount, receiversCount, pathwayMovedCount },
        } = data;

        // We create a new array that mirrors how the data should look like with the users data
        let newTabContent = [
            {
                title: 'PEOPLE/STEPS OF FAITH',
                key: 'MEMBERS',
                stats: `${receiversCount}  /  ${stepsCount}`,
            },
            {
                title: 'STEPS COMPLETED',
                key: 'STEPS_COMPLETED',
                stats: `${stepsCount}`,
            },
            {
                title: 'PEOPLE MOVEMENT',
                key: 'PEOPLE_MOVEMENT',
                stats: `${pathwayMovedCount}`,
            },
            {
                title: '',
                key: '',
                stats: '',
            },
        ];
        return newTabContent;
    };

    let userTabData = getTabsContent();

    // Define a variable that will be used to render tab data, depending if it has loaded or not
    let newTabContents;

    // TabsContent should be an array, but while it loads it is not
    // If its not an array we need our placeholder data so the component can be rendered
    angular.isArray(userTabData)
        ? (newTabContents = userTabData)
        : (newTabContents = tabsContent);

    return (
        <TabsContainer>
            {_.map(newTabContents, tab => (
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
    orgID: PropTypes.string,
    currentTab: PropTypes.string,
    title: PropTypes.string,
    value: PropTypes.string,
    key: PropTypes.string,
    active: PropTypes.bool,
    onTabClick: PropTypes.func,
};
