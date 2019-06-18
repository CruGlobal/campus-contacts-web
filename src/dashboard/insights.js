// Vendors
import React from 'react';
import PropTypes from 'prop-types';
import { ApolloProvider } from 'react-apollo-hooks';
import { react2angular } from 'react2angular';
import { ThemeProvider } from 'emotion-theming';
// Project
import { createApolloClient } from './apolloClient';
// Components
import Navigation from './components/navigation';

const theme = {
    colors: {
        light: '#A3A9AF',
    },
};

const Insights = ({ orgId, authenticationService }) => {
    const token = authenticationService.isTokenValid();
    const apolloClient = createApolloClient(token);

    return (
        <ApolloProvider client={apolloClient}>
            <ThemeProvider theme={theme}>
                <Navigation orgId={orgId} />
            </ThemeProvider>
        </ApolloProvider>
    );
};

Insights.propTypes = {
    orgId: PropTypes.string,
    theme: PropTypes.object,
    token: PropTypes.string,
};

angular
    .module('missionhubApp')
    .component(
        'insights',
        react2angular(Insights, ['orgId'], ['authenticationService']),
    );

export { Insights };
