// Vendors
import React from 'react';
import { useQuery } from 'react-apollo-hooks';
import PropTypes from 'prop-types';
import gql from 'graphql-tag';

const GET_ORGANIZATIONS = gql`
    query organization($id: ID!) {
        organization(id: $id) {
            id
            name
        }
    }
`;

const Navigation = ({ orgId }) => {
    const { data, loading, error } = useQuery(GET_ORGANIZATIONS, {
        variables: { id: orgId },
    });

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message} </div>;
    }

    const {
        organization: { name },
    } = data;

    return <div>Navigation: {name}</div>;
};

export default Navigation;

Navigation.propTypes = {
    orgId: PropTypes.string,
};
