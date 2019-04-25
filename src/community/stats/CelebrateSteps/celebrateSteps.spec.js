import React from 'react';
import { shallow } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_CELEBRATION_STEPS } from '../../graphql';
import CelebrateSteps from './celebrateSteps';
import Message from './message';
import _ from 'lodash';

function createClient(mocks) {
    return new ApolloClient({
        cache: new InMemoryCache(),
        link: new MockLink(mocks)
    })
}

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
                                __typename: 'celebrations',
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
        
        const celebrations = {
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
     
        
        const wrapper = shallow(
            <ApolloProvider client={createClient(mocks)}>
                <CelebrateSteps>
                    <h3>CELEBRATE</h3>
                {_.map(celebrations.data, message => (
                    <Message
                        message={message.message}
                        user={message.user}
                        key={message.key}
                    />
                ))}
                </CelebrateSteps>
            </ApolloProvider>,
        );
        expect(wrapper.html()).toBe('<div>Loading...</div>');
        await waitForNextTick();
       
        wrapper.update();
        
        expect(wrapper.find(Message).length).toBe(4);
        expect(wrapper.find(Message).at(0).key()).toBe('MESSAGE_1')
        expect(wrapper.find(Message).at(1).key()).toBe('MESSAGE_2')
        expect(wrapper.find(Message).at(2).key()).toBe('MESSAGE_3')
        expect(wrapper.find(Message).at(3).key()).toBe('MESSAGE_4')
        expect(wrapper.find(Message).at(0).prop('message')).toBe('Leah Completed a Step of Faith with a Curious person')
        expect(wrapper.find(Message).at(1).prop('message')).toBe('Leah Completed a Step of Faith with a Curious person')
        expect(wrapper.find(Message).at(2).prop('message')).toBe('Leah Completed a Step of Faith with a Curious person')
        expect(wrapper.find(Message).at(3).prop('message')).toBe('Leah Completed a Step of Faith with a Curious person')
        expect(wrapper.find(Message).at(0).prop('user')).toBe("Leah Brooks")
        expect(wrapper.find(Message).at(1).prop('user')).toBe("Leah Brooks")
        expect(wrapper.find(Message).at(2).prop('user')).toBe("Leah Brooks")
        expect(wrapper.find(Message).at(3).prop('user')).toBe("Leah Brooks")
    })
})