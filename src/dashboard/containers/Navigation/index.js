// Vendors
import React from 'react';
import styled from '@emotion/styled';
import { NavLink } from 'react-router-dom';
// Project
import AppContext from '../../appContext';

const NavigationBar = styled.div`
    background: #007398;
    height: 52px;
    padding-top: 15px;
    padding-bottom: 15px;
    padding-left: 18px;
    display: flex;
    justify-content: flex-start;
`;

const Link = styled(NavLink)`
    font-family: Titillium Web;
    font-style: normal;
    font-weight: normal;
    line-height: 21px;
    margin-right: 20px;
    color: white;
    position: relative;

    :hover {
        color: ${props => props.theme.colors.highlight};
        text-decoration: none;
    }

    &.active {
        color: ${props => props.theme.colors.highlight};
    }
`;

const Navigation = () => {
    const { orgId } = React.useContext(AppContext);
    return (
        <NavigationBar>
            <Link to={`/ministries/${orgId}/insights/personal`}>
                Personal Steps
            </Link>
            <Link to={`/ministries/${orgId}/insights/steps`}>
                Steps of Faith
            </Link>
            <Link to={`/ministries/${orgId}/insights/interactions`}>
                Interactions
            </Link>
            <Link to={`/ministries/${orgId}/insights/challenges`}>
                Challenges
            </Link>
        </NavigationBar>
    );
};

export default Navigation;

Navigation.propTypes = {};
