import styled from '@emotion/styled';
import React from 'react';
import PropTypes from 'prop-types';
import { withTheme } from 'emotion-theming';

const Container = styled.div`
    box-shadow: 0px 2px 12px rgba(0, 0, 0, 0.2);
    background: ${({ theme }: { theme: any }) => theme.colors.white};
    border-radius: 8px;
    padding-left: 24px;
    padding-right: 24px;
    padding-top: 43px;
    margin-top: 36px;
`;

const Title = styled.h1`
    font-weight: 300;
    font-size: 36px;
    line-height: 38px;
    color: ${({ theme }: { theme: any }) => theme.colors.primary};
    margin-bottom: 12px;
    margin-top: 0px;
`;

interface SubtitleProps {
    noMarginBottom: number;
}

const Subtitle = styled.h2<SubtitleProps>`
    font-size: 14px;
    line-height: 20px;
    font-weight: normal;
    color: ${({ theme }: { theme: any }) => theme.colors.primary};
    margin-top: 0;
    margin-bottom: ${(props: any) => (props.noMarginBottom ? '-40px' : '0')};
`;

interface ContentProps {
    noPadding: number;
}

const Content = styled.div<ContentProps>`
    padding: ${(props: any) => (props.noPadding ? 0 : '25px')};
    margin: ${(props: any) => (props.noPadding ? '0 -24px' : '0')};
`;

const Card = (props: any) => {
    const { title, subtitle, children, noPadding, noMarginBottom } = props;
    return (
        <Container>
            <Title>{title}</Title>
            <Subtitle noMarginBottom={noMarginBottom}>{subtitle}</Subtitle>
            <Content noPadding={noPadding}>{children}</Content>
        </Container>
    );
};

export default withTheme(Card);

Card.propTypes = {
    title: PropTypes.string,
    subtitle: PropTypes.string,
    children: PropTypes.element,
    noPadding: PropTypes.bool,
    noMarginBottom: PropTypes.bool,
};
