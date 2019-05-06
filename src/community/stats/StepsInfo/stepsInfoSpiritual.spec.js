import React from 'react';
import { mount } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_IMPACT_REPORT } from '../../graphql'
import StepsInfoSpiritual from './stepsInfoSpiritual';

function createClient(mocks) {
    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new MockLink(mocks),
    });
}

const waitForNextTick = () => new Promise(resolve => setTimeout(resolve));

describe('<StepsInfoSpiritual />', () => {
    it('should render correctly', async () => {
       
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
                <StepsInfoSpiritual orgID={15878}/>
            </ApolloProvider>
        );
        expect(wrapper.html()).toBe('<div>Loading...</div>');

        await waitForNextTick();
        wrapper.update();
       
        expect(wrapper.find('p').text()).toBe('0 people reached a new stage on their spiritual journey.')

    });
});
