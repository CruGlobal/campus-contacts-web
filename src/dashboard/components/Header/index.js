import styled from '@emotion/styled';
import React from 'react';

const Header = styled.h1`
    font-weight: 300;
    font-size: 36px;
    line-height: 38px;
    color: ${({ theme }) => theme.colors.highlightDarker};
    margin-bottom: 0px;
    margin-top: 48px;
    padding-left: 21px;
`;

export default Header;

Header.propTypes = {};
