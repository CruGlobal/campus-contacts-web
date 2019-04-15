import React from 'react';
import { mount } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_MEMBERS_GRAPHQL } from '../../graphql';
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
                    request: { query: GET_MEMBERS_GRAPHQL },
                    result: {
                        data: {
                            organization: {
                               __typename: 'Data',
                              name: "Campus Ministry",
                              id: 2,
                              stage_0: {
                                __typename: 'Data',
                                memberCount: 6,
                                id: "2-6-48.0.0",
                                name: "Not Sure",
                                pathwayStage: {
                                    __typename: 'Data',
                                    description: 'Hello',
                                    name: "Not Sure"
                                }
                                
                              },
                              stage_1: {
                                __typename: 'Data',
                                memberCount: 1,
                                id: "2-1-48.0.0",
                                name: "Uninterested",
                                pathwayStage: {
                                    __typename: 'Data',
                                    description: 'Hello',
                                    name: "Uninterested"
                                }
                              },
                              stage_2: {
                                __typename: 'Data',
                                memberCount: 2,
                                id: "2-2-48.0.0",
                                name: "Curious",
                                pathwayStage: {
                                    __typename: 'Data',
                                    description: 'Hello',
                                    name: "Curious"
                                }
                              },
                              stage_3: {
                                __typename: 'Data',
                                memberCount: 3,
                                id: "2-3-48.0.0",
                                name: "Forgiven",
                                pathwayStage: {
                                    __typename: 'Data',
                                    description: 'Hello',
                                    name: "Forgiven"
                                }
                              },
                              stage_4: {
                                __typename: 'Data',
                                memberCount: 4,
                                id: "2-4-48.0.0",
                                name: "Growing",
                                pathwayStage: {
                                    __typename: 'Data',
                                    description: 'Hello',
                                    name: "Growing"
                                }
                              },
                              stage_5: {
                                __typename: 'Data',
                                memberCount: 5,
                                id: "2-5-48.0.0",
                                name: "Guiding",
                                pathwayStage: {
                                    __typename: 'Data',
                                    description: 'Hello',
                                    name: "Guiding"
                                }
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

            expect(wrapper.find(BarStatCard).length).toBe(6);
            expect(wrapper.find(BarStatCard).at(0).key()).toBe('2-6-48.0.0');
            expect(wrapper.find(BarStatCard).at(0).prop('label')).toBe('Not Sure');
            expect(wrapper.find(BarStatCard).at(0).find('span').at(1).text()).toBe('Not Sure');
            expect(wrapper.find(BarStatCard).at(1).key()).toBe('2-1-48.0.0');
            expect(wrapper.find(BarStatCard).at(1).prop('label')).toBe('Uninterested');
            expect(wrapper.find(BarStatCard).at(1).find('span').at(1).text()).toBe('Uninterested');
            expect(wrapper.find(BarStatCard).at(2).key()).toBe('2-2-48.0.0');
            expect(wrapper.find(BarStatCard).at(2).prop('label')).toBe('Curious');
            expect(wrapper.find(BarStatCard).at(2).find('span').at(1).text()).toBe('Curious');
            expect(wrapper.find(BarStatCard).at(3).key()).toBe('2-3-48.0.0');
            expect(wrapper.find(BarStatCard).at(3).prop('label')).toBe('Forgiven');
            expect(wrapper.find(BarStatCard).at(3).find('span').at(1).text()).toBe('Forgiven');
            expect(wrapper.find(BarStatCard).at(4).key()).toBe('2-4-48.0.0');
            expect(wrapper.find(BarStatCard).at(4).prop('label')).toBe('Growing');
            expect(wrapper.find(BarStatCard).at(4).find('span').at(1).text()).toBe('Growing');
            expect(wrapper.find(BarStatCard).at(5).key()).toBe('2-5-48.0.0');
            expect(wrapper.find(BarStatCard).at(5).prop('label')).toBe('Guiding');
            expect(wrapper.find(BarStatCard).at(5).find('span').at(1).text()).toBe('Guiding');
  
    })
})