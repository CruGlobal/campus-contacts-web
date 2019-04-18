import React from 'react';
import { mount } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_ORGANIZATIONS } from '../../graphql';
import DashBoardNavBar from './navBar';

function createClient(mocks) {
    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new MockLink(mocks)
    })
}

const waitForNextTick = () => new Promise(resolve => setTimeout(resolve))

describe('<DashBoardNavBar />', () => {
    it("Should render properly", async () => {

        const mocks = [
            {
                request: { query: GET_ORGANIZATIONS },
                result: {
                    data: {
                        organization: {
                            __typename: 'Data',
                            name: 'Campus Ministry',
                            id: 2
                        }
                    }
                }
            }
        ]
       
        const wrapper = mount(
            <ApolloProvider client={createClient(mocks)}>
                <DashBoardNavBar></DashBoardNavBar>
            </ApolloProvider>
        )

        expect(wrapper.html()).toBe('<div>Loading...</div>');
        await waitForNextTick()
        wrapper.update()

        expect(wrapper.find('h1').text()).toBe('Campus Ministry')

    })
})