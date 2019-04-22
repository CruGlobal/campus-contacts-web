import React from 'react';
import { ApolloProvider } from 'react-apollo-hooks';
import PropTypes from 'prop-types';
import { react2angular } from 'react2angular';
import { ThemeProvider } from 'emotion-theming';
import Members from './Members/members';
import { client } from '../state/apollo-client';
import DashBoardNavBar from './NavBar/navBar';
import StepsInfo from './StepsInfo/StepsInfo';

const theme = {
    colors: {
        positive: '#00CA99',
        negative: '#FF5532',
        dark: '#505256',
        light: '#A3A9AF',
    },
};

const CommunityStats = ({ orgId }) => (
    <ApolloProvider client={client}>
        <ThemeProvider theme={theme}>
            <DashBoardNavBar orgID={orgId} />
            <StepsInfo />
            <Members />
        </ThemeProvider>
    </ApolloProvider>
);

CommunityStats.propTypes = {
    orgId: PropTypes.string,
    theme: PropTypes.object,
};

angular
    .module('missionhubApp')
    .component('communityStats', react2angular(CommunityStats));

export { CommunityStats };
