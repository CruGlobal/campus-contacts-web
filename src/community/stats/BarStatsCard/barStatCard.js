// COMPONENTS
import BarStatCard from './statCard';
// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import _ from 'lodash';
import { useQuery } from 'react-apollo-hooks';
// QUERIES
import { GET_MEMBERS, GET_CURRENT_FILTER } from '../../graphql';

// CSS
const BarChartCardRow = styled.div`
    margin-top: 80px;
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    grid-column-gap: 30px;
`;

const BarStats = () => {
    const { data, loading, error } = useQuery(GET_CURRENT_FILTER);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        apolloClient: {
            currentFilter: { key },
        },
    } = data;

    const switchMembersData = () => {
        switch (key) {
            case '1W': {
                const {
                    data: {
                        apolloClient: {
                            members: { members_1W },
                        },
                    },
                } = useQuery(GET_MEMBERS);
                return members_1W;
            }
            default: {
                const {
                    data: {
                        apolloClient: {
                            members: { members_default },
                        },
                    },
                } = useQuery(GET_MEMBERS);
                return members_default;
            }
        }
    };

    const MembersData = switchMembersData();

    return (
        <BarChartCardRow>
            {_.map(MembersData.data, member => (
                <BarStatCard
                    key={member.stage}
                    label={member.stage}
                    count={member.members}
                />
            ))}
        </BarChartCardRow>
    );
};

export default BarStats;

// PROPTYPES
BarStats.propTypes = {
    members: PropTypes.object,
    key: PropTypes.string,
    label: PropTypes.string,
    count: PropTypes.number,
};
