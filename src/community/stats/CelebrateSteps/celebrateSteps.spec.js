import React from 'react';
import { shallow } from 'enzyme';
import { ApolloClient } from 'apollo-client';
import { ApolloProvider } from 'react-apollo-hooks';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { MockLink } from 'apollo-link-mock';
import { GET_CELEBRATIONS_GRAPHQL } from '../../graphql';
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
                request: { query: GET_CELEBRATIONS_GRAPHQL, variables: {id: 15878} },
                result: {
                    data: {
                        organization: {
                            id: "15878",
                            organizationCelebrationItems: {
                              nodes: [
                                {
                                  id: "6044",
                                  objectType: "interaction",
                                  adjectiveAttributeValue: "5",
                                  subjectPerson: {
                                    fullName: "Christian Huffman",
                                    firstName: "Christian"
                                  }
                                },
                                {
                                  id: "6045",
                                  objectType: "interaction",
                                  adjectiveAttributeValue: "2",
                                  subjectPerson: {
                                    fullName: "Christian Huffman",
                                    firstName: "Christian"
                                  }
                                },
                                {
                                  id: "6046",
                                  objectType: "interaction",
                                  adjectiveAttributeValue: "3",
                                  subjectPerson: {
                                    fullName: "Christian Huffman",
                                    firstName: "Christian"
                                  }
                                },
                                {
                                  id: "6061",
                                  objectType: "interaction",
                                  adjectiveAttributeValue: "3",
                                  subjectPerson: {
                                    fullName: "Christian Huffman",
                                    firstName: "Christian"
                                  }
                                }
                              ]
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
                        'interaction',
                    user: {
                        fullName: 'Christian Huffman',
                        firstName: 'Chrsitian'
                    },
                    interactionType: 'Holy Spirit Presentation',
                    key: 'MESSAGE_1',
                },
                {
                    __typename: 'Data',
                    message:
                        'interaction',
                    user: {
                        fullName: 'Christian Huffman',
                        firstName: 'Chrsitian'
                    },
                    interactionType: 'Holy Spirit Presentation',
                    key: 'MESSAGE_2',
                },
                {
                    __typename: 'Data',
                    message:
                        'interaction',
                    user: {
                        fullName: 'Christian Huffman',
                        firstName: 'Chrsitian'
                    },
                    interactionType: 'Holy Spirit Presentation',
                    key: 'MESSAGE_3',
                },
                {
                    __typename: 'Data',
                    message:
                        'interaction',
                    user: {
                        fullName: 'Christian Huffman',
                        firstName: 'Chrsitian'
                    },
                    interactionType: 'Holy Spirit Presentation',
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
                            interactionType={message.interactionType}
                        />
                    ))}
                </CelebrateSteps>
            </ApolloProvider>,
        );
     
        await waitForNextTick();
       
        wrapper.update();
        
        expect(wrapper.find(Message).length).toBe(4);
        expect(wrapper.find(Message).at(0).key()).toBe('MESSAGE_1')
        expect(wrapper.find(Message).at(1).key()).toBe('MESSAGE_2')
        expect(wrapper.find(Message).at(2).key()).toBe('MESSAGE_3')
        expect(wrapper.find(Message).at(3).key()).toBe('MESSAGE_4')
        expect(wrapper.find(Message).at(0).prop('message')).toBe('interaction')
        expect(wrapper.find(Message).at(1).prop('message')).toBe('interaction')
        expect(wrapper.find(Message).at(2).prop('message')).toBe('interaction')
        expect(wrapper.find(Message).at(3).prop('message')).toBe('interaction')
        expect(wrapper.find(Message).at(0).prop('interactionType')).toBe('Holy Spirit Presentation')
        expect(wrapper.find(Message).at(1).prop('interactionType')).toBe('Holy Spirit Presentation')
        expect(wrapper.find(Message).at(2).prop('interactionType')).toBe('Holy Spirit Presentation')
        expect(wrapper.find(Message).at(3).prop('interactionType')).toBe('Holy Spirit Presentation')
    })
})