import styled from '@emotion/styled';

const Header = styled.h1`
    font-weight: 300;
    font-size: 30px;
    line-height: 38px;
    color: ${({ theme }: { theme: any }) => theme.colors.primary};
    margin-bottom: 0px;
    margin-top: 48px;
    padding-left: 21px;
`;

export default Header;
