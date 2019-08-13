import styled from '@emotion/styled';
import React, { useState } from 'react';
import { withTheme } from 'emotion-theming';
import PropTypes from 'prop-types';

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
    color: ${({ theme }) => theme.colors.secondary};
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
        background-color: ${({ theme }) => theme.colors.highlight};
        color: ${({ theme }) => theme.colors.white};
    }
`;

const SwitchButton = ({
    leftLabel,
    rightLabel,
    onLeftClick,
    onRightClick,
    isMonth,
}) => {
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

SwitchButton.propTypes = {
    leftLabel: PropTypes.string,
    rightLabel: PropTypes.string,
    onLeftClick: PropTypes.func,
    onRightClick: PropTypes.func,
};
