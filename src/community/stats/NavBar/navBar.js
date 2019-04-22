// COMPONENTS
import NavBarFilter from './navBarFilter';
// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
// QUERIES
import { GET_ORGANIZATIONS } from '../../graphql';

// CSS
const NavBar = styled.div`
    background: white;
    margin-bottom: 20px;
    border-radius: 5px;
    position: absolute;
    top: 50px;
    left: 0px;
    margin-bottom: 50px;
    width: 100vw;
    padding-bottom: 10px;
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
        font-weight: 100;
        margin-right: 30px;
        :hover {
            color: #007397;
            cursor: pointer;
        }
    }
`;

const DashBoardNavBar = ({ orgID }) => {
    const { data, loading, error } = useQuery(GET_ORGANIZATIONS);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message} </div>;
    }

    const {
        organization: { name },
    } = data;

    return (
        <NavBar>
            <h1>{name}</h1>
            <NavBarOutterContainer>
                <NavBarInnerContainer>
                    <h2>Dashboard</h2>
                    <h2>Insights</h2>
                </NavBarInnerContainer>
                <NavBarFilter />
            </NavBarOutterContainer>
        </NavBar>
    );
};

export default DashBoardNavBar;

// PROPTYPES
DashBoardNavBar.propTypes = {
    name: PropTypes.string,
    orgID: PropTypes.string,
};
