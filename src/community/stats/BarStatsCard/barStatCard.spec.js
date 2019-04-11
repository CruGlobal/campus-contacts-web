import React from 'react';
import { mount } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_MEMBERS } from '../../graphql';
import BarStats from './barStatCard';
import BarStatCard from './statCard';



function createClient(mocks) {
    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new MockLink(mocks)
    })
}

const waitForNextTick = () => new Promise(resolve => setTimeout(resolve))


describe('<BarStats />', () => {
    it('Should render Properly', async () => {       
            const mocks = [
                {
                    request: { query: GET_MEMBERS },
                    result: {
                        data: {
                            apolloClient: {
                                __typename: 'apolloClient',
                                members: {
                                    __typename: 'Members',
                                     data: [
                                    {
                                    __typename: 'Data',
                                    stage: 'No Stage',
                                    members: 10,
                                    stepsAdded: 12,
                                    stepsCompleted: 37,
                                    },
                                    {
                                    __typename: 'Data',
                                    stage: 'Not Sure',
                                    members: 11,
                                    stepsAdded: 34,
                                    stepsCompleted: 37,
                                    },
                                    {
                                    __typename: 'Data',
                                    stage: 'Uninterested',
                                    members: 12,
                                    stepsAdded: 53,
                                    stepsCompleted: 10,
                                    },
                                    {
                                    __typename: 'Data',
                                    stage: 'Curious',
                                    members: 13,
                                    stepsAdded: 23,
                                    stepsCompleted: 34,
                                    },
                                    {
                                    __typename: 'Data',
                                    stage: 'Forgiven',
                                    members: 14,
                                    stepsAdded: 53,
                                    stepsCompleted: 10,
                                    },
                                    {
                                    __typename: 'Data',
                                    stage: 'Growing',
                                    members: 15,
                                    stepsAdded: 53,
                                    stepsCompleted: 10,
                                    },
                                    {
                                    __typename: 'Data',
                                    stage: 'Guiding',
                                    members: 16,
                                    stepsAdded: 53,
                                    stepsCompleted: 10,
                                    },
                                    ],
                                }
                            }
                        }
                    }
                }
            ]
    
            const wrapper = mount(
                <ApolloProvider client={createClient(mocks)}>
                    <BarStats />
                </ApolloProvider>
            )
    
            expect(wrapper.html()).toBe('<div>Loading...</div>');
            await waitForNextTick()
            wrapper.update()

            console.log(wrapper.debug());
    })
})