import React from 'react';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';
import { useTranslation } from 'react-i18next';

import nullAdded from '../../assets/icons/null-added.svg';
import nullChallenges from '../../assets/icons/null-challenges.svg';
import nullCompleted from '../../assets/icons/null-completed.svg';
import nullInteractions from '../../assets/icons/null-interactions.svg';
import nullStages from '../../assets/icons/null-stages.svg';

interface Props {
    content?: string;
}

const LoadingContainer = styled.div<Props>`
    width: 100%;
    height: 190px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    background-color: ${({ theme }) => theme.colors.white};
    border-radius: 8px;
`;

const LoadingText = styled.p`
    text-align: center;
    width: 720px;
    color: ${({ theme }) => theme.colors.highlightDarker};
    font-size: 16px;
    font-weight: 300;
    line-height: 24px;
    margin: 10px 0;
`;

const NullState = ({ content }: Props) => {
    const { t } = useTranslation('insights');

    const getImageSrc = (content: string | undefined) => {
        switch (content) {
            case 'stepsOfFaithCompleted':
            case 'personalStepsCompleted':
                return nullCompleted;
            case 'personalStepsAdded':
            case 'stepsOfFaithAdded':
                return nullAdded;
            case 'communityMembersStages':
            case 'peopleStages':
                return nullStages;
            case 'interactionsCompleted':
                return nullInteractions;
            case 'challengesCompleted':
                return nullChallenges;
            default:
                return null;
        }
    };
    return (
        <LoadingContainer>
            <img src={getImageSrc(content)}></img>
            <LoadingText>{t(`nullState.${content}`)}</LoadingText>
        </LoadingContainer>
    );
};

export default withTheme(NullState);
