import styled from '@emotion/styled';
import React from 'react';
import PropTypes from 'prop-types';

const Title = styled.h1`
    font-weight: 300;
    font-size: 36px;
    line-height: 38px;
    color: ${({ theme }) => theme.colors.highlightDarker};
    margin-bottom: 0px;
    margin-top: 48px;
    padding-left: 21px;
`;

const Header = props => {
    const { title } = props;

    return <Title>{title}</Title>;
};

export default Header;

Header.propTypes = {
    title: PropTypes.string,
};
