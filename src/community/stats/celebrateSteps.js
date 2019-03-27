import React from 'react';
import styled from '@emotion/styled';

const Container = styled.div`
    width: 22%;
    height: 290px;
    border-radius: 5px;
`;

const InsideContainer = styled.div`
    background: white;
    padding-bottom: 20px;
    border-radius: 5px;
`;

const MessageContainer = styled.div`
    margin: 5px 10px;
`;

const Message = ({ message, user }) => (
    <MessageContainer>
        <h3>{user}</h3>
        <p>{message}</p>
    </MessageContainer>
);

export const CelebrateSteps = () => (
    <Container>
        <h3>CELEBRATE</h3>
        <InsideContainer>
            <Message
                message="Leah Completed A Personal Step of Faith"
                user="Leah Brooks"
            />
            <Message
                message="Leah Completed A Personal Step of Faith"
                user="Leah Brooks"
            />
            <Message
                message="Leah Completed A Personal Step of Faith"
                user="Leah Brooks"
            />
        </InsideContainer>
    </Container>
);
