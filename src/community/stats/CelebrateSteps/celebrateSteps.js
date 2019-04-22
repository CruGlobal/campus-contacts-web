// COMPONENTS
import Message from './message';
// LIBRARIES
import React from 'react';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
import PropTypes from 'prop-types';
// QUERIES
import { GET_CELEBRATION_STEPS } from '../../graphql';

// CSS
const Container = styled.div`
    width: 22%;
    height: 290px;
    border-radius: 5px;
`;

const InsideContainer = styled.div`
    background: white;
    border-radius: 5px;
    box-shadow: 0px 0px 15px -3px rgba(0, 0, 0, 0.16);
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

// PROPTYPES
CelebrateSteps.propTypes = {
    celebrations: PropTypes.object,
    message: PropTypes.string,
    user: PropTypes.string,
    key: PropTypes.string,
};
