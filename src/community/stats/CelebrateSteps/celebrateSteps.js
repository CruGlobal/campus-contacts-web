// COMPONENTS
import Message from './message';
// LIBRARIES
import React from 'react';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
import PropTypes from 'prop-types';
// QUERIES
import { GET_CELEBRATIONS_GRAPHQL } from '../../graphql';

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

export const CelebrateSteps = ({ orgID }) => {
    const { data, loading, error } = useQuery(GET_CELEBRATIONS_GRAPHQL, {
        variables: { id: orgID },
    });
    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        organization: { organizationCelebrationItems },
    } = data;

    const celebrationItems = _.takeRight(organizationCelebrationItems.nodes, 4);

    for (let i = 0; i < celebrationItems.length; i++) {
        let interactionType = celebrationItems[i].adjectiveAttributeValue;

        switch (interactionType) {
            case '2': {
                celebrationItems[i].adjectiveAttributeValue =
                    'Spiritual Conversation';
                break;
            }
            case '3': {
                celebrationItems[i].adjectiveAttributeValue =
                    'Personal Evangelism';
                break;
            }
            case '4': {
                celebrationItems[i].adjectiveAttributeValue =
                    'Personal Evangelism Decisions';
                break;
            }
            case '5': {
                celebrationItems[i].adjectiveAttributeValue =
                    'Holy Spirit Presentation';
                break;
            }
            case '6': {
                celebrationItems[i].adjectiveAttributeValue =
                    'Discipleship Conversation';
                break;
            }
            default: {
                celebrationItems[i].adjectiveAttributeValue = 'some sort of';
            }
        }
    }

    return (
        <Container>
            <h3>CELEBRATE</h3>
            <InsideContainer>
                {_.map(celebrationItems, message => (
                    <Message
                        message={message.objectType}
                        interactionType={message.adjectiveAttributeValue}
                        user={message.subjectPerson}
                        key={message.id}
                    />
                ))}
            </InsideContainer>
        </Container>
    );
};

export default CelebrateSteps;

// PROPTYPES
CelebrateSteps.propTypes = {
    celebrations: PropTypes.object,
    message: PropTypes.string,
    user: PropTypes.string,
    key: PropTypes.string,
};
