import React from 'react';
import styled from '@emotion/styled';

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
        margin-bottom: -2px;
    }
    > p {
        margin-bottom: -6px;
        padding-bottom: 9px;
    }
`;

const MessageConfig = [
    {
        message: 'Leah Completed A Personal Step of Faith',
        user: 'Leah Brooks',
        key: 'MESSAGE_1',
    },
    {
        message: 'Leah Completed A Personal Step of Faith',
        user: 'Leah Brooks',
        key: 'MESSAGE_2',
    },
    {
        message: 'Leah Completed A Personal Step of Faith',
        user: 'Leah Brooks',
        key: 'MESSAGE_3',
    },
    {
        message: 'Leah Completed A Personal Step of Faith',
        user: 'Leah Brooks',
        key: 'MESSAGE_4',
    },
];

const Message = ({ message, user }) => (
    <MessageContainer>
        <h3>{user}</h3>
        <p>{message}</p>
    </MessageContainer>
);

export const CelebrateSteps = () => {
    return (
        <Container>
            <h3>CELEBRATE</h3>
            <InsideContainer>
                {_.map(MessageConfig, message => (
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
