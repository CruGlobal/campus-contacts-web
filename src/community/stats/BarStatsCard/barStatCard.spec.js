import React from 'react';
import { shallow } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import {  GET_CURRENT_FILTER } from '../../graphql';
import BarStats from './barStatCard';
import BarStatCard from './statCard';
import _ from 'lodash';
import moment from 'moment';


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
                request: { query: GET_CURRENT_FILTER },
                result: {
                    data: {
                        apolloClient: {
                            __typename: 'apolloClient',
                            currentFilter: {
                                __typename: 'currentFilter',
                                key: '1W',
                                startDate: moment()
                                    .subtract(1, 'week')
                                    .format('l'),
                                endDate: moment().format('l'),
                            },
                        }
                    }
                }
            }
        ]
           
            const MembersData = {
                data: [
                    {
                        __typename: 'Data',
                        stage: 'No Stage',
                        members: 11,
                        stepsAdded: 23,
                        stepsCompleted: 14,
                    },
                    {
                        __typename: 'Data',
                        stage: 'Not Sure',
                        members: 12,
                        stepsAdded: 12,
                        stepsCompleted: 51,
                    },
                    {
                        __typename: 'Data',
                        stage: 'Uninterested',
                        members: 13,
                        stepsAdded: 32,
                        stepsCompleted: 23,
                    },
                    {
                        __typename: 'Data',
                        stage: 'Curious',
                        members: 14,
                        stepsAdded: 12,
                        stepsCompleted: 31,
                    },
                    {
                        __typename: 'Data',
                        stage: 'Forgiven',
                        members: 15,
                        stepsAdded: 19,
                        stepsCompleted: 27,
                    },
                    {
                        __typename: 'Data',
                        stage: 'Growing',
                        members: 16,
                        stepsAdded: 21,
                        stepsCompleted: 29,
                    },
                    {
                        __typename: 'Data',
                        stage: 'Guiding',
                        members: 17,
                        stepsAdded: 12,
                        stepsCompleted: 43,
                    },
                ]
            }
    
            const wrapper = shallow(
                <ApolloProvider client={createClient(mocks)}>
                    <BarStats>
                        {_.map(MembersData.data, member => (
                            <BarStatCard 
                            key={member.stage}
                            label={member.stage} 
                            count={member.members}>
                            </BarStatCard>
                        ))}
                    </BarStats>
                </ApolloProvider>
            )
    
            expect(wrapper.html()).toBe('<div>Loading...</div>');
            await waitForNextTick()
            wrapper.update()

            expect(wrapper.find(BarStatCard).length).toBe(7);
            expect(wrapper.find(BarStatCard).at(0).key()).toBe('No Stage');
            expect(wrapper.find(BarStatCard).at(0).prop('label')).toBe('No Stage');            
            expect(wrapper.find(BarStatCard).at(1).key()).toBe('Not Sure');
            expect(wrapper.find(BarStatCard).at(1).prop('label')).toBe('Not Sure');        
            expect(wrapper.find(BarStatCard).at(2).key()).toBe('Uninterested');
            expect(wrapper.find(BarStatCard).at(2).prop('label')).toBe('Uninterested');         
            expect(wrapper.find(BarStatCard).at(3).key()).toBe('Curious');
            expect(wrapper.find(BarStatCard).at(3).prop('label')).toBe('Curious');         
            expect(wrapper.find(BarStatCard).at(4).key()).toBe('Forgiven');
            expect(wrapper.find(BarStatCard).at(4).prop('label')).toBe('Forgiven');         
            expect(wrapper.find(BarStatCard).at(5).key()).toBe('Growing');
            expect(wrapper.find(BarStatCard).at(5).prop('label')).toBe('Growing');        
            expect(wrapper.find(BarStatCard).at(6).key()).toBe('Guiding');
            expect(wrapper.find(BarStatCard).at(6).prop('label')).toBe('Guiding'); 
    })
})