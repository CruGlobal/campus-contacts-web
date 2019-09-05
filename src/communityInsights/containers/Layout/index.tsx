import React from 'react';
import styled from '@emotion/styled';
import { BrowserRouter as Router, Route } from 'react-router-dom';

import Navigation from '../Navigation';
import PersonalStepsPage from '../PersonalStepsPage';
import StepsOfFaithPage from '../StepsOfFaithPage';
import InteractionsPage from '../InteractionsPage';
import ChallengesPage from '../ChallengesPage';

const LayoutWrapper = styled.div`
    display: flex;
    color: ${({ theme }) => theme.colors.primary};
    font-family: ${({ theme }) => theme.font.family};
    font-style: normal;
    font-weight: normal;
    font-size: ${({ theme }) => theme.font.size};
    line-height: 20px;
    flex-direction: column;
    background-color: #f2f2f2;
`;

const Content = styled.div`
    width: 100%;
`;

const Layout = () => {
    return (
        <LayoutWrapper>
            <Router>
                <Navigation />
                <Content>
                    <Route
                        path="/ministries/:id/insights/personal"
                        component={PersonalStepsPage}
                    />
                    <Route
                        path="/ministries/:id/insights/steps"
                        component={StepsOfFaithPage}
                    />
                    <Route
                        path="/ministries/:id/insights/interactions"
                        component={InteractionsPage}
                    />
                    <Route
                        path="/ministries/:id/insights/challenges"
                        component={ChallengesPage}
                    />
                </Content>
            </Router>
        </LayoutWrapper>
    );
};

export default Layout;
