// Vendors
import React from 'react';
import PropTypes from 'prop-types';
import Navigation from './navigation';
import styled from '@emotion/styled';
import PersonalSteps from './personalSteps';
import StepsOfFaith from './stepsOfFaith';
import { BrowserRouter as Router, Route } from 'react-router-dom';

const LayoutWrapper = styled.div`
    display: flex;
    color: ${props => props.theme.colors.primary};
    font-family: Source Sans Pro;
    font-style: normal;
    font-weight: normal;
    font-size: 14px;
    line-height: 20px;
    min-height: 100vh;
    flex-direction: column;
    justify-content: space-between;
    background: #2f2f2f;
    background-image: url(../assets/background-left.png),
        url(../assets/background-right.png);
    background-position: left 100px, right 120px;
    background-repeat: repeat-y, no-repeat;
    background-attachment: fixed, fixed;
`;

const Content = styled.div``;

const Layout = ({ orgId, person }) => {
    return (
        <LayoutWrapper>
            <Router>
                <Navigation orgId={orgId} person={person} />
                <Content>
                    <Route
                        path="/ministries/:id/insights/personal"
                        component={PersonalSteps}
                    />
                    <Route
                        path="/ministries/:id/insights/steps"
                        component={StepsOfFaith}
                    />
                    <Route
                        path="/ministries/:id/insights/interactions"
                        component={StepsOfFaith}
                    />
                    <Route
                        path="/ministries/:id/insights/challenges"
                        component={StepsOfFaith}
                    />
                </Content>
            </Router>
        </LayoutWrapper>
    );
};

export default Layout;

Layout.propTypes = {
    orgId: PropTypes.string,
};
