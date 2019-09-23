import React from 'react';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';

interface Props {
    width: number;
}

const LoadingContainer = styled.div<Props>`
    width: 100%;
    height: ${(props: Props) => props.width}px;
    background-color: ${({ theme }) => theme.colors.white};
    animation: fade 2s infinite linear both;
    border-radius: 8px;
    @keyframes fade {
        from {
            background-color: ${({ theme }) => theme.colors.white};
        }
        to {
            background-color: ${({ theme }) => theme.colors.highlight};
        }
    }
`;

const NullState = ({ width }: Props) => {
    return <LoadingContainer width={width} />;
};

export default withTheme(NullState);
