import React from 'react';
import { mount } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import {  GET_IMPACT_REPORT } from '../../graphql'
import StepsInfoPersonal from './stepsInfoPersonal';


function createClient(mocks) {
    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new MockLink(mocks),
    });
}

const waitForNextTick = () => new Promise(resolve => setTimeout(resolve));

describe('<StepsInfoPersonal />', () => {
    it('should render correctly with different message when there is only one member who has completed steps', async () => {
        const mocks = [
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
            },
        ];

        const wrapper = mount(
            <ApolloProvider client={createClient(mocks)}>
                <StepsInfoPersonal orgID={15878}/>
            </ApolloProvider>
        );
        expect(wrapper.html()).toBe('<div>Loading...</div>');

        await waitForNextTick();
        wrapper.update();
      
        expect(wrapper.find('p').text()).toBe('1 member has taken 32 steps with 4 people.')
    });
});

describe('<StepsInfoPersonal />', () => {
    it('should render correctly with different message when there is only multiple members have completed steps', async () => {
        const mocks = [
            {
                request: { query: GET_IMPACT_REPORT, variables: {id: 15878} },
                result: {   
                    data: {
                        impactReport: {
                            pathwayMovedCount: '0',
                            receiversCount: '4',
                            stepsCount: '32',
                            stepOwnersCount: '2',
                            __typename: "ImpactReport"
                        },
                    }
                },
            },
        ];

        const wrapper = mount(
            <ApolloProvider client={createClient(mocks)}>
                <StepsInfoPersonal orgID={15878}/>
            </ApolloProvider>
        );
        expect(wrapper.html()).toBe('<div>Loading...</div>');

        await waitForNextTick();
        wrapper.update();
      
        expect(wrapper.find('p').text()).toBe('2 members have taken 32 steps with 4 people.')
    });
});