import React from 'react';
import PropTypes from 'prop-types';
import { ApolloProvider } from 'react-apollo-hooks';
import { react2angular } from 'react2angular';
import { ThemeProvider } from 'emotion-theming';

import { createApolloClient } from '../apolloClient';
import { AppContext } from '../appContext';
import defaultTheme from '../defaultTheme';
import Layout from './containers/Layout';

interface Props {
    orgId: string;
    authenticationService: any;
}
const Insights = ({ orgId, authenticationService }: Props) => {
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

// @ts-ignore
angular.module('missionhubApp').component(
    'insights',
    // @ts-ignore
    react2angular(Insights, ['orgId'], ['authenticationService']),
);

export { Insights };
