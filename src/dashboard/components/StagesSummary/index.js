import React from 'react';
import styled from '@emotion/styled';
import { withTheme } from 'emotion-theming';
import PropTypes from 'prop-types';

const Stages = styled.div`
    display: flex;
    flex-direction: row;
    justify-content: space-around;
`;

const Stage = styled.div`
    display: flex;
    flex-direction: column;
    align-items: center;
`;

const Icon = styled.div`
    height: 52px;
    width: 52px;
    background-size: contain;
    background-repeat: no-repeat;

    &.not-sure {
        background-image: url(/src/dashboard/assets/icons/stage-not-sure.svg);
    }

    &.uninterested {
        background-image: url(/src/dashboard/assets/icons/stage-uninterested.svg);
    }

    &.curious {
        background-image: url(/src/dashboard/assets/icons/stage-curious.svg);
    }

    &.forgiven {
        background-image: url(/src/dashboard/assets/icons/stage-forgiven.svg);
    }

    &.growing {
        background-image: url(/src/dashboard/assets/icons/stage-growing.svg);
    }

    &.guiding {
        background-image: url(/src/dashboard/assets/icons/stage-guiding.svg);
    }
`;

const Title = styled.div`
    font-weight: 600;
    font-size: 12px;
    line-height: 14px;
    color: ${({ theme }) => theme.colors.secondary};
    margin-top: 17px;
`;

const Value = styled.div`
    font-weight: 600;
    font-size: 32px;
    line-height: 38px;
    color: ${({ theme }) => theme.colors.highlightDarker};
    margin-top: 9px;
`;

const StagesSummary = ({ summary }) => (
    <Stages>
        {summary.map(entry => (
            <Stage key={entry.stage}>
                <Icon className={entry.icon} />
                <Title>{entry.stage}</Title>
                <Value>{entry.count ? entry.count : '-'}</Value>
            </Stage>
        ))}
    </Stages>
);

export default withTheme(StagesSummary);

StagesSummary.propTypes = {
    summary: PropTypes.arrayOf(
        PropTypes.shape({
            stage: PropTypes.string.isRequired,
            icon: PropTypes.string.isRequired,
            count: PropTypes.number.isRequired,
        }),
    ).isRequired,
};
