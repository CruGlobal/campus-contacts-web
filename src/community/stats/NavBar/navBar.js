import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import NavBarFilter from './navBarFilter';

const NavBar = styled.div`
    background: white;
    margin-bottom: 20px;
    border-radius: 5px;
    position: absolute;
    top: 50px;
    left: 0px;
    margin-bottom: 50px;
    width: 100vw;
    > h1 {
        margin-left: 10px;
    }
`;

const NavBarOutterContainer = styled.div`
    display: flex;
    justify-content: space-between;
`;

const NavBarInnerContainer = styled.div`
    width: 100%;
    margin: 0 10px;
    display: flex;
    color: lightgrey;
    > h2 {
        margin-right: 30px;
        :hover {
            color: #007397;
            cursor: pointer;
        }
    }
`;

const DashBoardNavBar = ({ orgID }) => (
    <NavBar>
        <h1>Org Id: {orgID}</h1>
        <NavBarOutterContainer>
            <NavBarInnerContainer>
                <h2>Dashboard</h2>
                <h2>Insights</h2>
            </NavBarInnerContainer>
            <NavBarFilter />
        </NavBarOutterContainer>
    </NavBar>
);

export default DashBoardNavBar;
