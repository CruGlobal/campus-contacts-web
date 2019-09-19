import React from 'react';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';
import { useTranslation } from 'react-i18next';

interface Props {
    impactInfo?: boolean;
    width?: number;
}

const NullState = ({ impactInfo, width }: Props) => {
    const LoadingContainer = styled.div`
        width: 100%;
        height: ${width}px;
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
    const { t } = useTranslation('insights');

    return impactInfo ? (
        <span>{t('gatheringStats')}</span>
    ) : (
        <LoadingContainer />
    );
};

export default withTheme(NullState);
