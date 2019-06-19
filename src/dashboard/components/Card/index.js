import styled from '@emotion/styled';
import React from 'react';
import PropTypes from 'prop-types';

const Container = styled.div`
    box-shadow: 0px 2px 12px rgba(0, 0, 0, 0.2);
    overflow: hidden;
    background: ${props => props.theme.colors.white};
    border-radius: 8px;
    padding-left: 24px;
    padding-right: 24px;
    padding-top: 43px;
    margin-bottom: 36px;

    :first-child {
        border-radius: 0 0 8px 8px;
    }
`;

const Title = styled.h1`
    font-weight: 300;
    font-size: 36px;
    line-height: 38px;
    color: ${props => props.theme.colors.secondary};
    margin-bottom: 12px;
    margin-top: 0px;
`;

const Subtitle = styled.h2`
    font-size: 14px;
    line-height: 20px;
    font-weight: normal;
    color: ${props => props.theme.colors.primary};
    margin-top: 0;
`;

const Content = styled.div`
    padding: 25px;
`;

const Card = props => {
    const { title, subtitle, children } = props;

    return (
        <Container>
            <Title>{title}</Title>
            <Subtitle>{subtitle}</Subtitle>
            <Content>{children}</Content>
        </Container>
    );
};

export default Card;

Card.propTypes = {
    title: PropTypes.string,
    subtitle: PropTypes.string,
    children: PropTypes.element,
};
