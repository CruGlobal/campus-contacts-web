import React from 'react';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';

interface Props {
    width: number;
}

export const stepsOfFaithMockData = {
    community: {
        report: {
            interactions: [
                {
                    interactionCount: 0,
                    interactionType: {
                        name: 'Spiritual Conversation',
                    },
                },
                {
                    interactionCount: 0,
                    interactionType: {
                        name: 'Personal Evangelism',
                    },
                },
                {
                    interactionCount: 0,
                    interactionType: {
                        name: 'Personal Evangelism Decisions',
                    },
                },
                {
                    interactionCount: 0,
                    interactionType: {
                        name: 'Holy Spirit Presentation',
                    },
                },
                {
                    interactionCount: 0,
                    interactionType: {
                        name: 'Discipleship Conversation',
                    },
                },
            ],
            stagesReport: [
                {
                    personalStepsCompletedCount: 0,
                    stage: {
                        name: 'Uninterested',
                    },
                },
                {
                    personalStepsCompletedCount: 0,
                    stage: {
                        name: 'Curious',
                    },
                },
                {
                    personalStepsCompletedCount: 0,
                    stage: {
                        name: 'Forgiven',
                    },
                },
                {
                    personalStepsCompletedCount: 0,
                    stage: {
                        name: 'Growing',
                    },
                },
                {
                    personalStepsCompletedCount: 0,
                    stage: {
                        name: 'Guiding',
                    },
                },
                {
                    personalStepsCompletedCount: 0,
                    stage: {
                        name: 'Not Sure',
                    },
                },
            ],
        },
    },
};

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
