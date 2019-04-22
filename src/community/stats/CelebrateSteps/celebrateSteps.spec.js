import React from 'react';
import { shallow } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_CELEBRATION_STEPS } from '../../graphql';
import CelebrateSteps from './celebrateSteps';

const waitForNextTick = () => new Promise(resolve => setTimeout(resolve))

describe('<CelebrateSteps />', () => {
    it("Should render properly", async () => {
        const mocks = [
            {
                request: { query: GET_CELEBRATION_STEPS },
                result: {
                    data: {
                        apolloClient: {
                            __typename: 'apolloClient',
                            celebrations: {
                                data: [
                                    {
                                        __typename: 'Data',
                                        message:
                                            'Leah Completed a Step of Faith with a Curious person',
                                        user: 'Leah Brooks',
                                        key: 'MESSAGE_1',
                                    },
                                    {
                                        __typename: 'Data',
                                        message:
                                            'Leah Completed a Step of Faith with a Curious person',
                                        user: 'Leah Brooks',
                                        key: 'MESSAGE_2',
                                    },
                                    {
                                        __typename: 'Data',
                                        message:
                                            'Leah Completed a Step of Faith with a Curious person',
                                        user: 'Leah Brooks',
                                        key: 'MESSAGE_3',
                                    },
                                    {
                                        __typename: 'Data',
                                        message:
                                            'Leah Completed a Step of Faith with a Curious person',
                                        user: 'Leah Brooks',
                                        key: 'MESSAGE_4',
                                    },
                                ],
                            }
                        }
                    }
                },
                error: new Error("Something Went Wrong!")
            }
        ]

        function createClient(mocks) {
            return new ApolloClient({
                cache: new InMemoryCache(),
                link: new MockLink(mocks)
            })
        }
        
        const wrapper = shallow(
            <ApolloProvider client={createClient(mocks)}>
                <CelebrateSteps/>
            </ApolloProvider>,
        );
        expect(wrapper.html()).toBe('<div>Loading...</div>');
        await waitForNextTick();
        // After this wrapper.update it will just render out the component with the error div.
        wrapper.update();
    })
})