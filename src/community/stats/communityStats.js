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
// Apollo Client Libraries
import ApolloClient from 'apollo-client';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { ApolloLink } from 'apollo-link';
import { withClientState } from 'apollo-link-state';
import defaults from '../state/defaults';
import resolvers from '../resolvers';
import { createHttpLink } from 'apollo-link-http';

const theme = {
    colors: {
        positive: '#00CA99',
        negative: '#FF5532',
        dark: '#505256',
        light: '#A3A9AF',
    },
};

const CommunityStats = ({ orgId, authenticationService }) => {
    // Utilize authenticationService to grab jwt Token for headers auth
    const token = authenticationService.isTokenValid();
    // Initialize a new httpLink to our api
    const httplink = createHttpLink({
        uri: 'https://api-stage.missionhub.com/apis/graphql',
        includeExtensions: true,
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });

    const cache = new InMemoryCache();
    const stateLink = withClientState({
        cache,
        defaults,
        resolvers,
    });

    const client = new ApolloClient({
        cache,
        link: ApolloLink.from([stateLink, httplink]),
    });

    return (
        <ApolloProvider client={client}>
            <ThemeProvider theme={theme}>
                <DashBoardNavBar orgID={orgId} />
                <StepsInfo />
                <Members orgID={orgId} />
            </ThemeProvider>
        </ApolloProvider>
    );
};

CommunityStats.propTypes = {
    orgId: PropTypes.string,
    theme: PropTypes.object,
    token: PropTypes.string,
};

angular
    .module('missionhubApp')
    .component(
        'communityStats',
        react2angular(CommunityStats, ['orgId'], ['authenticationService']),
    );

export { CommunityStats };
