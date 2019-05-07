import React from 'react';
import { shallow } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';

import { GET_CURRENT_TAB, GET_IMPACT_REPORT} from '../../graphql';
import Tabs from './tabs';
import Tab from './tab';
import _ from 'lodash';

function createClient(mocks) {
    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new MockLink(mocks),
    });
}

const waitForNextTick = () => new Promise(resolve => setTimeout(resolve));

describe('<Tabs />', () => {
    it('should render 4 tabs with the first one active', async () => {
            const mocks = [
                {
                    request: { query: GET_CURRENT_TAB },
                    result: {
                        data: {
                            apolloClient: {
                                __typename: 'apolloClient',
                                currentTab: 'MEMBERS',
                            },
                        },
                    },
                },
                {
                    request: { query: GET_IMPACT_REPORT, variables: {id: 15878} },
                    result: {   
                        data: {
                            impactReport: {
                                pathwayMovedCount: '0',
                                receiversCount: '4',
                                stepsCount: '32',
                                stepOwnersCount: '1',
                                __typename: "ImpactReport"
                            },
                        }
                    },
                }
            ];

            const TabContent = [
                {
                    __typename: 'Data',
                    title: 'PEOPLE/STEPS OF FAITH',
                    key: 'MEMBERS',
                    stats: '4 / 32',
                },
                {
                    __typename: 'Data',
                    title: 'STEPS COMPLETED',
                    key: 'STEPS_COMPLETED',
                    stats: '32',
                },
                {
                    __typename: 'Data',
                    title: 'PEOPLE MOVEMENT',
                    key: 'PEOPLE_MOVEMENT',
                    stats: '0',
                },
                {
                    __typename: 'Data',
                    title: '',
                    key: '',
                    stats: '',
                },
            ]

            let currentTab = 'MEMBERS'
    
            const wrapper = shallow(
                <ApolloProvider client={createClient(mocks)}>
                    <Tabs orgID={'15878'} tabsContent={TabContent}>
                    {_.map(TabContent, tab => (
                        <Tab
                            title={tab.title}
                            value={tab.stats}
                            key={tab.key}
                            active={currentTab === tab.key ? 'true' : 'false'}
                            onTabClick={() => onTabClick(tab.key)}
                        />
                    ))}
                    </Tabs>
                </ApolloProvider>,
            );
    
            expect(wrapper.html()).toBe('<div>Loading</div>');
    
            await waitForNextTick();
            wrapper.update();
    
            expect(wrapper.find(Tab).length).toBe(4);
            expect(wrapper.find(Tab).at(0).key()).toBe('MEMBERS');
            expect(wrapper.find(Tab).at(0).prop('active')).toBe('true');
            expect(wrapper.find(Tab).at(1).key(),).toBe('STEPS_COMPLETED');
            expect(wrapper.find(Tab).at(1).prop('active')).toBe('false');
            expect(wrapper.find(Tab).at(2).key()).toBe('PEOPLE_MOVEMENT');
            expect(wrapper.find(Tab).at(2).prop('active')).toBe('false');
            expect(wrapper.find(Tab).at(3).key()).toBe('');
    });
});
