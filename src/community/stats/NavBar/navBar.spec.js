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
                request: { query: GET_ORGANIZATIONS, variables: {id: 15878} },
                result: {
                    data: {
                        organization: {
                            __typename: 'Data',
                            name: "Christian Huffman's Test Org",
                            id: 15878
                        }
                    }
                }
            }
        ]
       
        const wrapper = mount(
            <ApolloProvider client={createClient(mocks)}>
                <DashBoardNavBar orgID={15878}></DashBoardNavBar>
            </ApolloProvider>
        )

        expect(wrapper.html()).toBe('<div>Loading...</div>');
        await waitForNextTick()
        wrapper.update()

        expect(wrapper.find('h1').text()).toBe("Christian Huffman's Test Org")

    })
})