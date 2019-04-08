import React from 'react';
import styled from '@emotion/styled';
import { GET_CELEBRATION_STEPS } from '../../graphql';
import { useQuery } from 'react-apollo-hooks';
import Message from './message';

const Container = styled.div`
    width: 22%;
    height: 290px;
    border-radius: 5px;
`;

const InsideContainer = styled.div`
    background: white;
    border-radius: 5px;
`;

export const CelebrateSteps = () => {
    const { data, loading, error } = useQuery(GET_CELEBRATION_STEPS);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        apolloClient: { celebrations },
    } = data;

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

export default CelebrateSteps;
