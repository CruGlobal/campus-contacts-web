// Vendors
import React from 'react';
import PropTypes from 'prop-types';
import { ApolloProvider } from 'react-apollo-hooks';
import { react2angular } from 'react2angular';
import { ThemeProvider } from 'emotion-theming';

import { createApolloClient } from './apolloClient';
import AppContext from './appContext';
import defaultTheme from './defaultTheme';
import Layout from './containers/Layout';

const Insights = ({ orgId, authenticationService }) => {
    const token = authenticationService.isTokenValid();
    const apolloClient = createApolloClient(token);

    return (
        <ApolloProvider client={apolloClient}>
            <AppContext.Provider value={{ orgId }}>
                <ThemeProvider theme={defaultTheme}>
                    <Layout />
                </ThemeProvider>
            </AppContext.Provider>
        </ApolloProvider>
    );
};

Insights.propTypes = {
    orgId: PropTypes.string,
    authenticationService: PropTypes.object,
};

angular
    .module('missionhubApp')
    .component(
        'insights',
        react2angular(Insights, ['orgId'], ['authenticationService']),
    );

export { Insights };
