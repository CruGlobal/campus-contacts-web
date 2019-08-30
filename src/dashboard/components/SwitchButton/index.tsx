import styled from '@emotion/styled';
import React, { useState } from 'react';
import { withTheme } from 'emotion-theming';

const Container = styled.div`
    width: 145px;
    height: 32px;
    border-radius: 16px;
    overflow: hidden;
    display: flex;
`;

const Button = styled.div`
    width: 72px;
    background-color: #eceef2;
    text-align: center;
    display: flex;
    justify-content: center;
    align-items: center;
    color: ${({ theme }: { theme: any }) => theme.colors.secondary};
    font-size: 14px;
    line-height: 20px;

    &:not(:last-child) {
        margin-right: 1px;
    }

    &:hover {
        background-color: #e2e2e2;
        cursor: pointer;
    }

    &.active {
        background-color: ${({ theme }: { theme: any }) =>
            theme.colors.highlight};
        color: ${({ theme }: { theme: any }) => theme.colors.white};
    }
`;

interface Props {
    leftLabel: string;
    rightLabel: string;
    onLeftClick: () => void;
    onRightClick: () => void;
    isMonth: boolean;
}

const SwitchButton = ({
    leftLabel,
    rightLabel,
    onLeftClick,
    onRightClick,
    isMonth,
}: Props) => {
    const [isLeftActive, setLeftActive] = useState(isMonth);

    const leftClicked = () => {
        setLeftActive(true);
        onLeftClick();
    };

    const rightClicked = () => {
        setLeftActive(false);
        onRightClick();
    };

    return (
        <Container>
            <Button
                className={isLeftActive ? 'active' : ''}
                onClick={leftClicked}
            >
                {leftLabel}
            </Button>
            <Button
                className={isLeftActive ? '' : 'active'}
                onClick={rightClicked}
            >
                {rightLabel}
            </Button>
        </Container>
    );
};

export default withTheme(SwitchButton);
