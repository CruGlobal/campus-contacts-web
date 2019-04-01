import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import StagesBarGraph from '../Graphs/stagesBarGraph';
import StagesLineGraph from '../Graphs/stagesLineGraph';
import { CelebrateSteps } from '../CelebrateSteps/celebrateSteps';
import { GET_CURRENT_TAB } from '../../graphql';
import { useQuery } from 'react-apollo-hooks';
import Tabs from '../Tabs/tabs';
import BarStats from '../BarStatsCard/barStatCard';

const Container = styled.div`
    display: flex;
    flex-direction: row;
    align-items: space-between;
    justify-content: space-between;
    margin-top: 20px;
`;

const InnerContainer = styled.div`
    width: 75%;
    height: 220px;
    margin-bottom: 30px;
    border-radius: 0 0 5px 5px;
    > div {
        background: white;
    }
`;

const Members = ({ positive, negative }) => {
    const {
        data: {
            apolloClient: { currentTab },
        },
    } = useQuery(GET_CURRENT_TAB);

    const renderGraph = () => {
        switch (currentTab) {
            case 'MEMBERS':
                return <StagesBarGraph />;
            case 'STEPS_COMPLETED':
                return <StagesLineGraph />;
            default:
                return <div />;
        }
    };

    return (
        <>
            <Container>
                <InnerContainer>
                    <h3>STEPS OF FAITH WITH OTHERS</h3>
                    <Tabs />
                    {renderGraph()}
                </InnerContainer>
                <CelebrateSteps />
            </Container>

            <BarStats positive={positive} negative={negative} />
        </>
    );
};

export default Members;
