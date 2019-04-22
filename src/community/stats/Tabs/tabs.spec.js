import React from 'react';
import { mount } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';

import { GET_CURRENT_TAB, GET_TAB_CONTENT } from '../../graphql';
import Tabs from './tabs';
import Tab from './tab';

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
                    request: { query: GET_TAB_CONTENT },
                    result: {
                        data: {
                            apolloClient: {
                                tabsContent: {
                                    __typename: 'tabsConfig',
                                    data: [
                                        {
                                            __typename: 'Data',
                                            title: 'PEOPLE/STEPS OF FAITH',
                                            key: 'MEMBERS',
                                            stats: '40 / 120',
                                        },
                                        {
                                            __typename: 'Data',
                                            title: 'STEPS COMPLETED',
                                            key: 'STEPS_COMPLETED',
                                            stats: '20',
                                        },
                                        {
                                            __typename: 'Data',
                                            title: 'PEOPLE MOVEMENT',
                                            key: 'PEOPLE_MOVEMENT',
                                            stats: '2',
                                        },
                                        {
                                            __typename: 'Data',
                                            title: '',
                                            key: '',
                                            stats: '',
                                        },
                                    ],
                                },
                            }
                        }
                    }
                },
            ];
    
            const wrapper = mount(
                <ApolloProvider client={createClient(mocks)}>
                    <Tabs />
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
