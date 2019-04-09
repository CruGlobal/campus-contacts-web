import React from 'react';
import { ApolloProvider } from 'react-apollo-hooks';
import PropTypes from 'prop-types';
import { react2angular } from 'react2angular';
import { ThemeProvider } from 'emotion-theming';
import Members from './Members/members';
import { client } from '../state/apollo-client';
import DashBoardNavBar from './NavBar/navBar';
import StepsInfo from './StepsInfo/StepsInfo';
import { Spring } from 'react-spring/renderprops';

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
            <Spring from={{ opacity: 0 }} to={{ opacity: 1 }}>
                {props => <StepsInfo style={props} />}
            </Spring>
            <Spring from={{ opacity: 0 }} to={{ opacity: 1 }}>
                {props => (
                    <Members
                        style={props}
                        positive={theme.positive}
                        negative={theme.negative}
                    />
                )}
            </Spring>
        </ThemeProvider>
    </ApolloProvider>
);

CommunityStats.propTypes = {
    orgId: PropTypes.string,
};

angular
    .module('missionhubApp')
    .component('communityStats', react2angular(CommunityStats));

export { CommunityStats };
