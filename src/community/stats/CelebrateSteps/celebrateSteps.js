// COMPONENTS
import Message from './message';
// LIBRARIES
import React from 'react';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
import PropTypes from 'prop-types';
// QUERIES
import {
    GET_CELEBRATIONS_GRAPHQL,
    GET_MORE_CELEBRATIONS_ITEMS,
} from '../../graphql';

// CSS
const Container = styled.div`
    width: 22%;
    height: 290px;
    border-radius: 5px;
`;

const InsideContainer = styled.div`
    background: white;
    border-radius: 5px;
    height: 290px;
    overflow: scroll;
    box-shadow: 0px 0px 15px -3px rgba(0, 0, 0, 0.16);
`;
const PaginationContainer = styled.div`
    display: flex;
    justify-content: space-between;
    margin: 0 25px 5px; 10px;
`;
const PaginationItem = styled.span`
    :hover {
        border-bottom: 1px #007397 solid;
        cursor: pointer;
    }
`;

const CelebrateSteps = ({ orgID }) => {
    const { data, loading, error, fetchMore } = useQuery(
        GET_CELEBRATIONS_GRAPHQL,
        {
            variables: { id: orgID },
        },
    );
    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        organization: { organizationCelebrationItems },
    } = data;

    let celebrationItems = organizationCelebrationItems;

    const fetchPreviousCelebration = cursor => {
        fetchMore({
            query: GET_MORE_CELEBRATIONS_ITEMS,
            variables: { before: cursor, id: orgID, after: null },
            updateQuery: (previousResult, { fetchMoreResult }) => {
                return (celebrationItems = fetchMoreResult);
            },
        });
    };
    const fetchNextCelebration = cursor => {
        fetchMore({
            query: GET_MORE_CELEBRATIONS_ITEMS,
            variables: { after: cursor, id: orgID, before: null },
            updateQuery: (previousResult, { fetchMoreResult }) => {
                return (celebrationItems = fetchMoreResult);
            },
        });
    };

    for (let i = 0; i < celebrationItems.nodes.length; i++) {
        let interactionType = celebrationItems.nodes[i].adjectiveAttributeValue;

        switch (interactionType) {
            case '2': {
                celebrationItems.nodes[i].adjectiveAttributeValue =
                    'a Spiritual Conversation';
                break;
            }
            case '3': {
                celebrationItems.nodes[i].adjectiveAttributeValue =
                    'a Personal Evangelism';
                break;
            }
            case '4': {
                celebrationItems.nodes[i].adjectiveAttributeValue =
                    'a Personal Evangelism Decisions';
                break;
            }
            case '5': {
                celebrationItems.nodes[i].adjectiveAttributeValue =
                    'a Holy Spirit Presentation';
                break;
            }
            case '6': {
                celebrationItems.nodes[i].adjectiveAttributeValue =
                    'a Discipleship Conversation';
                break;
            }
            default: {
                celebrationItems.nodes[i].adjectiveAttributeValue =
                    'some sort of';
            }
        }
    }

    return (
        <Container>
            <h3>CELEBRATE</h3>
            <InsideContainer>
                {_.map(celebrationItems.nodes, message => (
                    <Message
                        message={message.objectType}
                        interactionType={message.adjectiveAttributeValue}
                        user={message.subjectPerson}
                        key={message.id}
                    />
                ))}
                <PaginationContainer>
                    <PaginationItem
                        onClick={() =>
                            fetchPreviousCelebration(
                                celebrationItems.edges[0].cursor,
                            )
                        }
                    >
                        Last Page
                    </PaginationItem>

                    <PaginationItem
                        onClick={() =>
                            fetchNextCelebration(
                                celebrationItems.edges[
                                    celebrationItems.edges.length - 1
                                ].cursor,
                            )
                        }
                    >
                        Next Page
                    </PaginationItem>
                </PaginationContainer>
            </InsideContainer>
        </Container>
    );
};

export { CelebrateSteps };

// PROPTYPES
CelebrateSteps.propTypes = {
    celebrationsItems: PropTypes.object,
    message: PropTypes.string,
    user: PropTypes.object,
    key: PropTypes.string,
};
