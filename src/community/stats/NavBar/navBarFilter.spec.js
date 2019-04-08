import React from 'react';
import { mount } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_CURRENT_FILTER } from '../../graphql';
import Filter from './navBarFilter';
import moment from 'moment';

function createClient(mocks) {
    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new MockLink(mocks)
    })
}

const waitForNextTick = () => new Promise(resolve => setTimeout(resolve))

describe('<NavBarFilter />', () => {
    it('it should render correctly', async () => {
        const mocks = [
            {
                request: { query: GET_CURRENT_FILTER },
                result: {
                    data: {
                        apolloClient: {
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
        const wrapper = mount(
            <ApolloProvider client={createClient(mocks)}>
                <Filter />
            </ApolloProvider>
        );
        expect(wrapper.html()).toBe('<div>Loading</div>');
        await waitForNextTick();
        wrapper.update();

       
    });
});
