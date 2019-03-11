import React from 'react';
import PropTypes from 'prop-types';
import { react2angular } from 'react2angular';
import styled from '@emotion/styled';
import { ThemeProvider } from 'emotion-theming';

const Card = styled.div`
    background-color: white;
    border-radius: 8px;
    padding: 18px;
`;
const StatNumber = styled.span`
    font-size: 32px;
    font-weight: bold;
    color: ${({ positive, negative, theme: { colors } }) =>
        positive ? colors.positive : negative ? colors.negative : colors.dark};
`;

const StatLabel = styled.span`
    font-size: 11px;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: ${({
        theme: {
            colors: { light },
        },
    }) => light};
`;

const BarStatCardLayout = styled(Card)`
    display: grid;
    grid-template-rows: repeat(3, 1fr);
    grid-column-gap: 30px;
`;

const BarStatCard = ({ count, label, positive, negative }) => (
    <BarStatCardLayout>
        <StatNumber positive={positive} negative={negative}>
            {count}
        </StatNumber>
        <StatLabel>{label}</StatLabel>
    </BarStatCardLayout>
);

const BarChartCardRow = styled.div`
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    grid-column-gap: 30px;
`;

const Members = () => (
    <BarChartCardRow>
        <BarStatCard label="Not Sure" count={10} />
        <BarStatCard label="Uninterested" count={11} positive />
        <BarStatCard label="Curious" count={12} />
        <BarStatCard label="Forgiven" count={13} negative />
        <BarStatCard label="Growing" count={14} />
        <BarStatCard label="Guiding" count={15} />
    </BarChartCardRow>
);

const theme = {
    colors: {
        positive: '#00CA99',
        negative: '#FF5532',
        dark: '#505256',
        light: '#A3A9AF',
    },
};

const CommunityStats = ({ orgId }) => (
    <ThemeProvider theme={theme}>
        <h1>Org Id: {orgId}</h1>
        <Members />
    </ThemeProvider>
);

CommunityStats.propTypes = {
    orgId: PropTypes.string,
};

angular
    .module('missionhubApp')
    .component('communityStats', react2angular(CommunityStats));

export { CommunityStats };
