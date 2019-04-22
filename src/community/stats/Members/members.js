import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import StagesBarGraph from '../Graphs/stagesBarGraph';
import StagesLineGraph from '../Graphs/stagesLineGraph';
import { CelebrateSteps } from '../CelebrateSteps/celebrateSteps';
import { GET_CURRENT_TAB, GET_TAB_CONTENT } from '../../graphql';
import { useQuery } from 'react-apollo-hooks';
import Tabs from '../Tabs/tabs';
import BarStats from '../BarStatsCard/barStatCard';
import { useSpring, animated } from 'react-spring';
import TabContent from '../Tabs/tabContent';

const Container = styled(animated.div)`
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
        box-shadow: 0px 0px 15px -3px rgba(0, 0, 0, 0.16);
    }
`;

const Members = () => {
    const { data, loading, error } = useQuery(GET_CURRENT_TAB);

    if (loading) {
        return <div>Loading...</div>;
    }

    if (error) {
        return <div>Error! {error.message}</div>;
    }

    const {
        apolloClient: { currentTab },
    } = data;

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

    const props = useSpring({
        delay: '1000',
        opacity: 1,
        from: { opacity: 0 },
    });

    const tabContent = TabContent();

    return (
        <>
            <Container style={props}>
                <InnerContainer>
                    <h3>STEPS OF FAITH WITH OTHERS</h3>
                    <Tabs tabsContent={tabContent} />
                    {renderGraph()}
                </InnerContainer>
                <CelebrateSteps />
            </Container>

            <BarStats />
        </>
    );
};

export default Members;

Members.propTypes = {
    currentTab: PropTypes.string,
    renderGraph: PropTypes.func,
};
