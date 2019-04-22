// LIBRARIES
import React from 'react';
import styled from '@emotion/styled';
import PropTypes from 'prop-types';

// CSS
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
const Message = ({ message, user }) => {
    return (
        <MessageContainer>
            <h3>{user}</h3>
            <p>{message}</p>
        </MessageContainer>
    );
};

export default Message;

// PROPTYPES
Message.propTypes = {
    message: PropTypes.string,
    user: PropTypes.string,
};
