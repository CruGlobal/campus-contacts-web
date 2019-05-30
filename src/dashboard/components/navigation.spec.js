import React from 'react';
import { mount } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_ORGANIZATIONS } from '../graphql';
import Navigation from './navigation';

function createClient(mocks) {
    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new MockLink(mocks),
    });
}

const waitForNextTick = () => new Promise(resolve => setTimeout(resolve));

describe('<Navigation />', () => {
    it('should render properly', async () => {
        const mocks = [
            {
                request: { query: GET_ORGANIZATIONS, variables: { id: '1' } },
                result: {
                    data: {
                        organization: {
                            __typename: 'Data',
                            name: 'Test Organization',
                            id: '1',
                        },
                    },
                },
            },
        ];

        const wrapper = mount(
            <ApolloProvider client={createClient(mocks)}>
                <Navigation orgId={'1'} />
            </ApolloProvider>,
        );

        expect(wrapper.html()).toBe('<div>Loading...</div>');
        await waitForNextTick();
        wrapper.update();

        expect(wrapper.find('div').text()).toBe(
            'Navigation: Test Organization',
        );
    });
});
