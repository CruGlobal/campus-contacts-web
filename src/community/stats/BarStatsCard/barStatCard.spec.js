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

            expect(wrapper.find(BarStatCard).length).toBe(7);
            expect(wrapper.find(BarStatCard).at(0).key()).toBe('No Stage');
            expect(wrapper.find(BarStatCard).at(0).prop('label')).toBe('No Stage');
            expect(wrapper.find(BarStatCard).at(0).find('span').at(1).text()).toBe('No Stage');
            expect(wrapper.find(BarStatCard).at(1).key()).toBe('Not Sure');
            expect(wrapper.find(BarStatCard).at(1).prop('label')).toBe('Not Sure');
            expect(wrapper.find(BarStatCard).at(1).find('span').at(1).text()).toBe('Not Sure');
            expect(wrapper.find(BarStatCard).at(2).key()).toBe('Uninterested');
            expect(wrapper.find(BarStatCard).at(2).prop('label')).toBe('Uninterested');
            expect(wrapper.find(BarStatCard).at(2).find('span').at(1).text()).toBe('Uninterested');
            expect(wrapper.find(BarStatCard).at(3).key()).toBe('Curious');
            expect(wrapper.find(BarStatCard).at(3).prop('label')).toBe('Curious');
            expect(wrapper.find(BarStatCard).at(3).find('span').at(1).text()).toBe('Curious');
            expect(wrapper.find(BarStatCard).at(4).key()).toBe('Forgiven');
            expect(wrapper.find(BarStatCard).at(4).prop('label')).toBe('Forgiven');
            expect(wrapper.find(BarStatCard).at(4).find('span').at(1).text()).toBe('Forgiven');
            expect(wrapper.find(BarStatCard).at(5).key()).toBe('Growing');
            expect(wrapper.find(BarStatCard).at(5).prop('label')).toBe('Growing');
            expect(wrapper.find(BarStatCard).at(5).find('span').at(1).text()).toBe('Growing');
            expect(wrapper.find(BarStatCard).at(6).key()).toBe('Guiding');
            expect(wrapper.find(BarStatCard).at(6).prop('label')).toBe('Guiding');
            expect(wrapper.find(BarStatCard).at(6).find('span').at(1).text()).toBe('Guiding');
  
    })
})