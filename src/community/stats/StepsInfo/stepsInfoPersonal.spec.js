import React from 'react';
import { mount } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_STEPSINFO_PERSONAL } from '../../graphql'
import StepsInfoPersonal from './stepsInfoPersonal';

// For some reason this mock won't connect and it being read as undefined
const mocks = [
    {
        request: { query: GET_STEPSINFO_PERSONAL },
        result: {   
            data: {
              apolloClient: {
                __typename: 'apolloClient',
                stepsInfoPersonal: {
                  __typename: 'stepsInfoPersonal',
                  userStats: 20,
                  numberStats: 120,
                  peopleStats: 40
                }
              }
            }
        },
    },
];

function createClient(mocks) {
    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new MockLink(mocks),
    });
}

const waitForNextTick = () => new Promise(resolve => setTimeout(resolve));

describe('<StepsInfoPersonal />', () => {
    it('should render correctly', async () => {

        const wrapper = mount(
            <ApolloProvider client={createClient(mocks)}>
                <StepsInfoPersonal />
            </ApolloProvider>
        );
        expect(wrapper.html()).toBe('<div>Loading...</div>');

        await waitForNextTick();
        wrapper.update();
 
    });
});
