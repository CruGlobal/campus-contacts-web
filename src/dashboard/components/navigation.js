// Vendors
import React from 'react';
import gql from 'graphql-tag';
import { useQuery } from 'react-apollo-hooks';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { NavLink } from 'react-router-dom';
// Project
import backButton from '../assets/back-button.svg';

const GET_ORGANIZATIONS = gql`
    query organization($id: ID!) {
        organization(id: $id) {
            id
            name
        }
    }
`;
const NavigationWrapper = styled.div``;

const Main = styled.div`
    background: white;
    height: 72px;
    padding-left: 25px;
    padding-right: 25px;
    width: 100vw;
    display: flex;
    justify-content: space-between;
    align-items: center;
`;

const Sub = styled.div`
    background: #007398;
    height: 48px;
    padding-top: 14px;
    padding-bottom: 14px;
    width: 100vw;
    display: flex;
    justify-content: center;
`;

const BackContainer = styled.div`
    width: 200px;
    display: flex;
    align-items: center;
    flex-grow: 1;
`;

const BackLink = styled.a`
    color: #505256;
    text-decoration: none;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;

    :hover {
        color: #007398;
        text-decoration: none;
    }

    img {
        margin-right: 10px;
    }
`;

const UserContainer = styled.div`
    width: 200px;
    height: 30px;
    flex-grow: 1;
    justify-content: flex-end;
    display: flex;
    align-items: center;
`;

const UserAvatar = styled.img`
    width: 36px;
    height: 36px;
    border-radius: 30px;
`;

const UserName = styled.div`
    line-height: 20px;
    color: #505256;
    margin-right: 15px;
`;

const LinksContainer = styled.div`
    flex-grow: 3;
    display: flex;
    justify-content: center;
`;

const MainStyledLink = styled(NavLink)`
    color: #505256;
    margin: 0 10px;
    position: relative;

    :hover {
        color: #007398;
        text-decoration: none;
    }

    &.active {
        color: #007398;

        ::after {
            content: '';
            position: absolute;
            bottom: -28px;
            left: 40%;
            border-bottom: 6px solid #007398;
            border-left: 6px solid transparent;
            border-right: 6px solid transparent;
            width: 0;
        }
    }
`;

const StyledLink = styled(NavLink)`
    margin: 0 10px;
    color: #3cc8e6;
    position: relative;

    :hover {
        color: #ffffff;
        text-decoration: none;
    }

    &.active {
        color: #ffffff;

        ::after {
            content: '';
            position: absolute;
            bottom: -14px;
            left: 50%;
            border-bottom: 6px solid #2f2f2f;
            border-left: 6px solid transparent;
            border-right: 6px solid transparent;
            width: 0;
        }
    }
`;

const Navigation = ({ orgId, person }) => {
    const { data, loading, error } = useQuery(GET_ORGANIZATIONS, {
        variables: { id: orgId },
    });

    if (loading) {
        return <NavigationWrapper>Loading...</NavigationWrapper>;
    }

    if (error) {
        return <NavigationWrapper>Error! {error.message} </NavigationWrapper>;
    }

    let name = 'Loading...';
    if (!loading) {
        name = data.organization.name;
    }

    return (
        <NavigationWrapper>
            <Main>
                <BackContainer>
                    <BackLink href={`/ministries/${orgId}/people`}>
                        <img src={backButton} /> {name}
                    </BackLink>
                </BackContainer>
                <LinksContainer>
                    <MainStyledLink to={`/ministries/${orgId}/suborgs`}>
                        Ministries
                    </MainStyledLink>
                    <MainStyledLink to={`/ministries/${orgId}/team`}>
                        Team
                    </MainStyledLink>
                    <MainStyledLink to={`/ministries/${orgId}/groups`}>
                        Groups
                    </MainStyledLink>
                    <MainStyledLink to={`/ministries/${orgId}/people`}>
                        Contacts
                    </MainStyledLink>
                    <MainStyledLink to={`/ministries/${orgId}/surveyResponses`}>
                        Survey Responses
                    </MainStyledLink>
                    <MainStyledLink to={`/ministries/${orgId}/surveys`}>
                        Surveys
                    </MainStyledLink>
                    <MainStyledLink to={`/ministries/${orgId}/tools`}>
                        Tools
                    </MainStyledLink>
                    <MainStyledLink to={`/ministries/${orgId}/insights/`}>
                        Insights
                    </MainStyledLink>
                </LinksContainer>
                <UserContainer>
                    <UserName>{person.full_name}</UserName>
                    <UserAvatar src={person.picture} />
                </UserContainer>
            </Main>
            <Sub>
                <StyledLink to={`/ministries/${orgId}/insights/personal`}>
                    Personal Steps
                </StyledLink>
                <StyledLink to={`/ministries/${orgId}/insights/steps`}>
                    Steps of Faith
                </StyledLink>
                <StyledLink to={`/ministries/${orgId}/insights/interactions`}>
                    Interactions
                </StyledLink>
                <StyledLink to={`/ministries/${orgId}/insights/challenges`}>
                    Challenges
                </StyledLink>
            </Sub>
        </NavigationWrapper>
    );
};

export default Navigation;

Navigation.propTypes = {
    orgId: PropTypes.string,
};
