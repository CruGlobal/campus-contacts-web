import React from 'react';
import { mount } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_STEPSINFO_SPIRITUAL } from '../../graphql'
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
        // For some reason this mock won't connect and it being read as undefined
        const mocks = [
            {
                request: { query: GET_STEPSINFO_SPIRITUAL },
                result: {
                    data: {
                        apolloClient: {
                            __typename: 'apolloClient',
                            stepsInfoSpiritual: {
                                __typename: 'stepsInfoSpiritual',
                                userStats: 20,
                            },
                        },
                    },
                },
            },
        ];

        const wrapper = mount(
            <ApolloProvider client={createClient(mocks)}>
                <StepsInfoSpiritual />
            </ApolloProvider>
        );
        expect(wrapper.html()).toBe('<div>Loading...</div>');

        await waitForNextTick();
        wrapper.update();
 
    });
});
