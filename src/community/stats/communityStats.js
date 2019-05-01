// COMPONENTS
import Members from './Members/members';
import DashBoardNavBar from './NavBar/navBar';
import StepsInfo from './StepsInfo/StepsInfo';
// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import { ApolloProvider } from 'react-apollo-hooks';
import { react2angular } from 'react2angular';
import { ThemeProvider } from 'emotion-theming';
import { client } from '../state/apollo-client';

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
            <Members orgID={orgId} />
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
