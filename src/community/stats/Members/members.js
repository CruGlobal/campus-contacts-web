// COMPONENTS
import StagesBarGraph from '../Graphs/stagesBarGraph';
import StagesLineGraph from '../Graphs/stagesLineGraph';
import Tabs from '../Tabs/tabs';
import BarStats from '../BarStatsCard/barStatCard';
import { tabContent } from '../Tabs/tabContent';
// LIBRARIES
import React from 'react';
import PropTypes from 'prop-types';
import styled from '@emotion/styled';
import { useQuery } from 'react-apollo-hooks';
import { useSpring, animated } from 'react-spring';
// QUERIES
import { CelebrateSteps } from '../CelebrateSteps/celebrateSteps';
import { GET_CURRENT_TAB } from '../../graphql';

// CSS
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

// COMPONENT
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

    // ANIMATION
    const props = useSpring({
        delay: '1000',
        opacity: 1,
        from: { opacity: 0 },
    });

    const TabContent = tabContent();

    return (
        <>
            <Container style={props}>
                <InnerContainer>
                    <h3>STEPS OF FAITH WITH OTHERS</h3>
                    <Tabs tabsContent={TabContent} />
                    {renderGraph()}
                </InnerContainer>
                <CelebrateSteps />
            </Container>

            <BarStats />
        </>
    );
};

export default Members;

// PROPTYPES CHECKING
Members.propTypes = {
    currentTab: PropTypes.string,
    renderGraph: PropTypes.func,
    tabContent: PropTypes.func,
};
