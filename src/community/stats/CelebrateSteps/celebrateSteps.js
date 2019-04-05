import React from 'react';
import styled from '@emotion/styled';
import { GET_CELEBRATION_STEPS } from '../../graphql';
import { useQuery } from 'react-apollo-hooks';

const Container = styled.div`
    width: 22%;
    height: 290px;
    border-radius: 5px;
`;

const InsideContainer = styled.div`
    background: white;
    border-radius: 5px;
`;

const MessageContainer = styled.div`
    margin: 5px 10px;
    > h3 {
        margin-bottom: -1px;
    }
    > p {
        margin-bottom: -6px;
        padding-bottom: 8px;
        color: grey;
    }
`;

const Message = ({ message, user }) => (
    <MessageContainer>
        <h3>{user}</h3>
        <p>{message}</p>
    </MessageContainer>
);

export const CelebrateSteps = () => {
    const {
        data: {
            apolloClient: { celebrations },
        },
        error,
        loading,
    } = useQuery(GET_CELEBRATION_STEPS);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    return (
        <Container>
            <h3>CELEBRATE</h3>
            <InsideContainer>
                {_.map(celebrations.data, message => (
                    <Message
                        message={message.message}
                        user={message.user}
                        key={message.key}
                    />
                ))}
            </InsideContainer>
        </Container>
    );
};
