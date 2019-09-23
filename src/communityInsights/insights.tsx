import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { ApolloProvider } from 'react-apollo-hooks';
import { react2angular } from 'react2angular';
import { ThemeProvider } from 'emotion-theming';

import { createApolloClient } from '../apolloClient';
import { AppContext } from '../appContext';
import { missionhubTheme } from '../missionhubTheme';

import Layout from './containers/Layout';

interface Props {
    orgId: string;
    authenticationService: any;
    insightsUpdateModalService: any;
}
const Insights = ({
    orgId,
    authenticationService,
    insightsUpdateModalService,
}: Props) => {
    const token = authenticationService.isTokenValid();
    const apolloClient = createApolloClient(token);
    // TODO Remove once no longer needed
    useEffect(() => {
        insightsUpdateModalService.checkModalConfirmation()
            ? null
            : insightsUpdateModalService.createModal();
    }, []);

    return (
        <ApolloProvider client={apolloClient}>
            <AppContext.Provider value={{ orgId }}>
                <ThemeProvider theme={missionhubTheme}>
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
    react2angular(
        Insights,
        ['orgId'],
        ['authenticationService', 'insightsUpdateModalService'],
    ),
);

export { Insights };
