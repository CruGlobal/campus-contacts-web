// Vendors
import React from 'react';
import PropTypes from 'prop-types';
import { ApolloProvider } from 'react-apollo-hooks';
import { react2angular } from 'react2angular';
import { ThemeProvider } from 'emotion-theming';
// Project
import { createApolloClient } from './apolloClient';
import AppContext from './appContext';
// Components
import Layout from './components/layout';

const theme = {
    colors: {
        primary: '#505256',
    },
};

const Insights = ({
    orgId,
    authenticationService,
    loggedInPerson,
    $rootScope,
}) => {
    const { person } = loggedInPerson;
    const token = authenticationService.isTokenValid();
    const apolloClient = createApolloClient(token);

    return (
        <ApolloProvider client={apolloClient}>
            <AppContext.Provider
                value={{
                    auth: authenticationService,
                    person,
                    root: $rootScope,
                }}
            >
                <ThemeProvider theme={theme}>
                    <Layout orgId={orgId} person={person} />
                </ThemeProvider>
            </AppContext.Provider>
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
        react2angular(
            Insights,
            ['orgId'],
            ['authenticationService', 'loggedInPerson', '$rootScope'],
        ),
    );

export { Insights };
